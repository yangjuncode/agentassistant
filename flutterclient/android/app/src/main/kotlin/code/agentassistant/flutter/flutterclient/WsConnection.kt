package code.agentassistant.flutter.flutterclient

import android.util.Log
import code.agentassistant.flutter.flutterclient.proto.WebsocketMessage
import java.util.concurrent.TimeUnit
import kotlin.math.min
import kotlin.math.pow
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import okio.ByteString
import okio.ByteString.Companion.toByteString

/**
 * 单个服务器的 WebSocket 连接（由前台 Service 持有）。
 * 负责：建连、发送 UserLogin、应用层心跳、断线重连。
 * 协议语义仍在 Dart 侧，这里只做管道 + 保活。
 */
class WsConnection(
    val serverId: String,
    var url: String,
    var token: String,
    var nickname: String,
    private val scope: CoroutineScope,
    private val listener: Listener,
) {

    interface Listener {
        fun onStatus(serverId: String, status: String)
        fun onFrame(serverId: String, data: ByteArray)
        fun onError(serverId: String, message: String)
    }

    companion object {
        private const val TAG = "WsConnection"
        private const val HEARTBEAT_INTERVAL_MS = 30_000L
        private const val RECONNECT_BASE_MS = 1_000L
        private const val RECONNECT_MAX_MS = 60_000L
    }

    private val client = OkHttpClient.Builder()
        .pingInterval(0, TimeUnit.MILLISECONDS) // 应用层心跳由我们自己发
        .build()

    @Volatile
    private var webSocket: WebSocket? = null
    private var heartbeatJob: Job? = null
    private var reconnectJob: Job? = null
    private var reconnectAttempts = 0

    @Volatile
    var manuallyDisconnected = false
        private set

    @Volatile
    var loggedIn = false
        private set

    /** 登录成功后保存，引擎重附着时回放给 Dart */
    @Volatile
    var clientId = ""
        private set

    @Volatile
    var serverVersion = ""
        private set

    /** 建立连接（幂等：已连接时只回放当前状态） */
    fun connect() {
        if (webSocket != null) {
            listener.onStatus(serverId, if (loggedIn) "connected" else "connecting")
            return
        }
        manuallyDisconnected = false
        reconnectJob?.cancel()
        listener.onStatus(serverId, "connecting")
        openSocket()
    }

    private fun openSocket() {
        val request = Request.Builder().url(url).build()
        webSocket = client.newWebSocket(request, socketListener)
    }

    /** 发送原始 protobuf 帧（Dart 侧构造好的 WebsocketMessage） */
    fun sendFrame(data: ByteArray): Boolean {
        val ws = webSocket ?: return false
        return ws.send(data.toByteString())
    }

    /** 主动断开（不再重连） */
    fun disconnect() {
        manuallyDisconnected = true
        reconnectJob?.cancel()
        heartbeatJob?.cancel()
        webSocket?.close(1000, "client disconnect")
        webSocket = null
        loggedIn = false
    }

    /** 立即重连（重置退避） */
    fun reconnect() {
        reconnectAttempts = 0
        disconnect()
        manuallyDisconnected = false
        connect()
    }

    /** 更新昵称：本地记录并立刻重发 UserLogin */
    fun updateNickname(newNickname: String) {
        nickname = newNickname
        if (loggedIn) sendUserLogin()
    }

    private fun sendUserLogin() {
        val message = WebsocketMessage.newBuilder()
            .setCmd("UserLogin")
            .setStrParam(token)
            .setNickname(nickname)
            .build()
        webSocket?.send(message.toByteString().toByteArray().toByteString())
    }

    private fun sendHeartbeat() {
        val message = WebsocketMessage.newBuilder()
            .setCmd("GetPendingMessages")
            .build()
        webSocket?.send(message.toByteString().toByteArray().toByteString())
    }

    private fun startHeartbeat() {
        heartbeatJob?.cancel()
        heartbeatJob = scope.launch {
            while (true) {
                delay(HEARTBEAT_INTERVAL_MS)
                if (webSocket == null || !loggedIn) continue
                sendHeartbeat()
            }
        }
    }

    private fun scheduleReconnect() {
        if (manuallyDisconnected) return
        reconnectJob?.cancel()
        reconnectAttempts += 1
        val delayMs = min(
            RECONNECT_MAX_MS,
            (RECONNECT_BASE_MS * 2.0.pow((reconnectAttempts - 1).toDouble())).toLong(),
        )
        listener.onStatus(serverId, "reconnecting")
        reconnectJob = scope.launch {
            delay(delayMs)
            if (!manuallyDisconnected && webSocket == null) {
                listener.onStatus(serverId, "connecting")
                openSocket()
            }
        }
    }

    /**
     * 回调里的 socket 是否为当前持有的一条。
     * 旧 socket 的异步回调（onClosed/onFailure/onMessage）可能在新 socket
     * 建立后才到达，必须按引用区分，否则会把新 socket 的引用清掉并多拉起
     * 一条连接——孤儿 socket 仍收服务器推送，导致同一消息重复投递。
     */
    private fun isCurrentSocket(ws: WebSocket): Boolean = ws === this.webSocket

    private val socketListener = object : WebSocketListener() {
        override fun onOpen(webSocket: WebSocket, response: Response) {
            if (!isCurrentSocket(webSocket)) {
                webSocket.cancel()
                return
            }
            Log.i(TAG, "[$serverId] socket open, sending UserLogin")
            sendUserLogin()
        }

        override fun onMessage(webSocket: WebSocket, bytes: ByteString) {
            if (!isCurrentSocket(webSocket)) {
                // 孤儿 socket 仍在收帧：说明服务器侧没踢它，主动掐掉
                Log.w(TAG, "[$serverId] frame on stale socket, cancelling it")
                webSocket.cancel()
                return
            }
            val data = bytes.toByteArray()
            // 登录响应要先于转发判断连接状态
            try {
                val message = WebsocketMessage.parseFrom(data)
                if (message.cmd == "UserLogin" && message.hasUserLoginResponse()) {
                    val resp = message.userLoginResponse
                    if (resp.success) {
                        Log.i(TAG, "[$serverId] login ok, clientId=${resp.clientId}")
                        loggedIn = true
                        clientId = resp.clientId
                        serverVersion = message.strParam
                        reconnectAttempts = 0
                        listener.onStatus(serverId, "connected")
                        startHeartbeat()
                    } else {
                        Log.e(TAG, "[$serverId] login failed: ${resp.errorMessage}")
                        listener.onError(serverId, "Login failed: ${resp.errorMessage}")
                        listener.onStatus(serverId, "error")
                    }
                }
            } catch (e: Exception) {
                Log.w(TAG, "[$serverId] failed to parse frame for login check", e)
            }
            listener.onFrame(serverId, data)
        }

        override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
            if (!isCurrentSocket(webSocket)) {
                Log.d(TAG, "[$serverId] stale socket failure ignored: ${t.message}")
                return
            }
            Log.w(TAG, "[$serverId] socket failure: ${t.message}")
            this@WsConnection.webSocket = null
            loggedIn = false
            heartbeatJob?.cancel()
            listener.onError(serverId, "Connection error: ${t.message}")
            listener.onStatus(serverId, "disconnected")
            scheduleReconnect()
        }

        override fun onClosed(webSocket: WebSocket, code: Int, reason: String) {
            if (!isCurrentSocket(webSocket)) {
                Log.d(TAG, "[$serverId] stale socket closed ignored: $code $reason")
                return
            }
            Log.i(TAG, "[$serverId] socket closed: $code $reason")
            this@WsConnection.webSocket = null
            loggedIn = false
            heartbeatJob?.cancel()
            listener.onStatus(serverId, "disconnected")
            scheduleReconnect()
        }

        override fun onClosing(webSocket: WebSocket, code: Int, reason: String) {
            webSocket.close(code, reason)
        }
    }
}

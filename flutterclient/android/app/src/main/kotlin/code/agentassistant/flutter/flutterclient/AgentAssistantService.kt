package code.agentassistant.flutter.flutterclient

import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.util.Log
import code.agentassistant.flutter.flutterclient.proto.WebsocketMessage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import org.json.JSONArray
import org.json.JSONObject

/**
 * WebSocket 前台服务：进程保活 + socket 保活 + 系统通知。
 *
 * 职责边界：
 * - 持有每条服务器的 socket（登录/心跳/重连）
 * - Dart 引擎在线：把原始帧转发给 Dart（协议语义不变）
 * - Dart 引擎离线：缓冲帧（重开后回放）并发系统通知
 *
 * 进程被杀后系统按 START_STICKY 重启服务时，用持久化的连接配置自动重连。
 */
class AgentAssistantService : Service() {

    companion object {
        private const val TAG = "AgentAssistantService"
        private const val PREFS_NAME = "aa_service_prefs"
        private const val KEY_TOKEN = "token"
        private const val KEY_NICKNAME = "nickname"
        private const val KEY_SERVERS = "servers"
        private const val MAX_BUFFERED_FRAMES = 500

        /** 常驻通知「退出」按钮触发的 action：断开连接并结束整个进程 */
        const val ACTION_EXIT = "code.agentassistant.flutter.flutterclient.ACTION_EXIT"

        /** Dart 侧事件回调（同进程直传，由插件层设置/清除） */
        var eventSink: ((Map<String, Any?>) -> Unit)? = null

        /**
         * App 是否在前台（前台时不弹系统通知）。
         * 放 companion：Service 重建或未绑定时标志依然生效。
         */
        @Volatile
        var uiForeground = false

        /** 当前是否在运行（供插件层判断） */
        var runningInstance: AgentAssistantService? = null
            private set
    }

    inner class LocalBinder : Binder() {
        fun getService(): AgentAssistantService = this@AgentAssistantService
    }

    private val binder = LocalBinder()
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val connections = HashMap<String, WsConnection>()
    private val statusMap = HashMap<String, String>()
    private val bufferLock = Any()
    private val frameBuffer = ArrayDeque<Pair<String, ByteArray>>()

    /** Dart 引擎是否附着（附着时帧直接转发，离线时缓冲） */
    @Volatile
    var clientAttached = false
        private set

    override fun onCreate() {
        super.onCreate()
        runningInstance = this
        NotificationHelper.ensureChannels(this)
        Log.i(TAG, "service created")
    }

    override fun onBind(intent: Intent?): IBinder = binder

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_EXIT) {
            exitApp()
            // NOT_STICKY：进程被杀后不允许系统再把服务拉起来
            return START_NOT_STICKY
        }
        goForeground()
        // 进程重启后（无 Dart 介入）按持久化配置恢复连接
        if (connections.isEmpty()) {
            restoreConnections()
        }
        return START_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        // 划卡不退出：服务继续运行，保持连接和通知
        Log.i(TAG, "task removed, keep running")
        super.onTaskRemoved(rootIntent)
    }

    override fun onDestroy() {
        runningInstance = null
        for (conn in connections.values) conn.disconnect()
        connections.clear()
        Log.i(TAG, "service destroyed")
        super.onDestroy()
    }

    /**
     * 通知栏「退出」按钮：断开所有连接、移除全部通知，
     * 然后结束整个进程（UI 与 Service 同进程，一并退出）。
     */
    private fun exitApp() {
        Log.i(TAG, "exit requested from notification")
        // 清掉自愈重连配置，防止进程死后服务被拉起又自动连上
        getSharedPreferences(PREFS_NAME, MODE_PRIVATE).edit().clear().apply()
        for (conn in connections.values) conn.disconnect()
        connections.clear()
        (getSystemService(NOTIFICATION_SERVICE) as? android.app.NotificationManager)
            ?.cancelAll()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
        android.os.Process.killProcess(android.os.Process.myPid())
    }

    private fun goForeground() {
        val notification = NotificationHelper.buildServiceNotification(
            this,
            serviceStatusText(),
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NotificationHelper.SERVICE_NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC,
            )
        } else {
            startForeground(NotificationHelper.SERVICE_NOTIFICATION_ID, notification)
        }
    }

    private fun serviceStatusText(): String {
        val total = connections.size
        val connected = connections.values.count { it.loggedIn }
        return if (total == 0) "保持后台服务" else "已连接 $connected/$total 个服务器"
    }

    private fun updateServiceNotification() {
        val nm = getSystemService(NOTIFICATION_SERVICE) as? android.app.NotificationManager
            ?: return
        nm.notify(
            NotificationHelper.SERVICE_NOTIFICATION_ID,
            NotificationHelper.buildServiceNotification(this, serviceStatusText()),
        )
    }

    // ------------------------------------------------------------------
    // 配置持久化（进程重启后自愈重连）
    // ------------------------------------------------------------------

    private fun persistConfig() {
        val prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        val servers = JSONArray()
        for (conn in connections.values) {
            servers.put(JSONObject().put("id", conn.serverId).put("url", conn.url))
        }
        val token = connections.values.firstOrNull()?.token
        val nickname = connections.values.firstOrNull()?.nickname
        prefs.edit()
            .putString(KEY_SERVERS, servers.toString())
            .putString(KEY_TOKEN, token)
            .putString(KEY_NICKNAME, nickname)
            .apply()
    }

    private fun restoreConnections() {
        val prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        val token = prefs.getString(KEY_TOKEN, null) ?: return
        val nickname = prefs.getString(KEY_NICKNAME, "") ?: ""
        val raw = prefs.getString(KEY_SERVERS, null) ?: return
        try {
            val servers = JSONArray(raw)
            for (i in 0 until servers.length()) {
                val s = servers.getJSONObject(i)
                connect(s.getString("id"), s.getString("url"), token, nickname)
            }
            Log.i(TAG, "restored ${servers.length()} connections after restart")
        } catch (e: Exception) {
            Log.w(TAG, "failed to restore connections", e)
        }
    }

    // ------------------------------------------------------------------
    // 对插件层暴露的命令
    // ------------------------------------------------------------------

    fun connect(serverId: String, url: String, token: String, nickname: String) {
        goForeground()
        val conn = connections[serverId]
        if (conn != null) {
            conn.url = url
            conn.token = token
            conn.nickname = nickname
            conn.connect()
        } else {
            connections[serverId] = WsConnection(
                serverId = serverId,
                url = url,
                token = token,
                nickname = nickname,
                scope = scope,
                listener = wsListener,
            ).also { it.connect() }
        }
        persistConfig()
        updateServiceNotification()
    }

    fun disconnect(serverId: String) {
        connections.remove(serverId)?.disconnect()
        statusMap[serverId] = "disconnected"
        emitEvent(mapOf("type" to "status", "serverId" to serverId, "status" to "disconnected"))
        persistConfig()
        updateServiceNotification()
        if (connections.isEmpty()) {
            Log.i(TAG, "all connections closed, stopping service")
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
        }
    }

    fun disconnectAll() {
        for (id in connections.keys.toList()) disconnect(id)
    }

    fun reconnect(serverId: String) {
        connections[serverId]?.reconnect()
    }

    /** Dart 侧构造好的 WebsocketMessage 原始字节，直接写入 socket */
    fun sendFrame(serverId: String, data: ByteArray): Boolean {
        val conn = connections[serverId] ?: return false
        return conn.sendFrame(data)
    }

    fun updateNickname(nickname: String) {
        for (conn in connections.values) conn.updateNickname(nickname)
        persistConfig()
    }

    /** Dart 引擎附着：回放登录信息/连接状态 + 缓冲帧 */
    fun onClientAttached() {
        clientAttached = true
        for (conn in connections.values) {
            if (conn.loggedIn) {
                emitEvent(
                    mapOf(
                        "type" to "login",
                        "serverId" to conn.serverId,
                        "clientId" to conn.clientId,
                        "serverVersion" to conn.serverVersion,
                    ),
                )
            }
        }
        for ((id, status) in statusMap) {
            emitEvent(mapOf("type" to "status", "serverId" to id, "status" to status))
        }
        flushBuffer()
    }

    /** Dart 引擎脱离：后续帧进入缓冲 + 系统通知 */
    fun onClientDetached() {
        clientAttached = false
    }

    // ------------------------------------------------------------------
    // 帧分发：转发 Dart / 缓冲 / 通知
    // ------------------------------------------------------------------

    private val wsListener = object : WsConnection.Listener {
        override fun onStatus(serverId: String, status: String) {
            statusMap[serverId] = status
            emitEvent(mapOf("type" to "status", "serverId" to serverId, "status" to status))
            updateServiceNotification()
        }

        override fun onFrame(serverId: String, data: ByteArray) {
            if (clientAttached) {
                emitEvent(mapOf("type" to "frame", "serverId" to serverId, "data" to data))
            } else {
                bufferFrame(serverId, data)
            }
            // 引擎离线等同于不在前台：必须弹系统通知
            if (!AgentAssistantService.uiForeground || !clientAttached) {
                notifyForFrame(serverId, data)
            }
        }

        override fun onError(serverId: String, message: String) {
            emitEvent(mapOf("type" to "error", "serverId" to serverId, "message" to message))
        }
    }

    private fun emitEvent(event: Map<String, Any?>) {
        eventSink?.invoke(event)
    }

    private fun bufferFrame(serverId: String, data: ByteArray) {
        synchronized(bufferLock) {
            if (frameBuffer.size >= MAX_BUFFERED_FRAMES) {
                frameBuffer.removeFirst()
            }
            frameBuffer.addLast(serverId to data)
        }
    }

    private fun flushBuffer() {
        val pending: List<Pair<String, ByteArray>>
        synchronized(bufferLock) {
            pending = frameBuffer.toList()
            frameBuffer.clear()
        }
        for ((serverId, data) in pending) {
            emitEvent(mapOf("type" to "frame", "serverId" to serverId, "data" to data))
        }
        if (pending.isNotEmpty()) {
            Log.i(TAG, "flushed ${pending.size} buffered frames to client")
        }
    }

    // ------------------------------------------------------------------
    // 系统通知
    // ------------------------------------------------------------------

    private fun notifyForFrame(serverId: String, data: ByteArray) {
        val message = try {
            WebsocketMessage.parseFrom(data)
        } catch (e: Exception) {
            return
        }
        when (message.cmd) {
            "AskQuestion" -> notifyAskQuestion(message)
            "WorkReport" -> notifyWorkReport(message)
            "GetPendingMessages" -> notifyPendingMessages(message)
            "ChatMessageNotification" -> notifyChatMessage(message)
            "AskQuestionReplyNotification" -> notifyGenericReply(
                requestId = message.askQuestionRequest.getID(),
                channel = NotificationHelper.CHANNEL_QUESTIONS,
                keyPrefix = "aq",
                title = "问题已被回复",
            )
            "WorkReportReplyNotification" -> notifyGenericReply(
                requestId = message.workReportRequest.getID(),
                channel = NotificationHelper.CHANNEL_REPORTS,
                keyPrefix = "wr",
                title = "汇报已被确认",
            )
        }
    }

    private fun notifyAskQuestion(message: WebsocketMessage) {
        val req = message.askQuestionRequest
        val questions = req.request.questionsList.joinToString("\n") { it.question }
            .ifEmpty { "新的问题" }
        NotificationHelper.notifyMessage(
            this,
            NotificationHelper.CHANNEL_QUESTIONS,
            "新问题",
            questions,
            NotificationHelper.messageNotificationId("aq_${req.getID()}"),
        )
    }

    private fun notifyWorkReport(message: WebsocketMessage) {
        val req = message.workReportRequest
        NotificationHelper.notifyMessage(
            this,
            NotificationHelper.CHANNEL_REPORTS,
            "新工作汇报",
            req.request.summary.ifEmpty { "新的工作汇报" },
            NotificationHelper.messageNotificationId("wr_${req.getID()}"),
        )
    }

    private fun notifyPendingMessages(message: WebsocketMessage) {
        if (!message.hasGetPendingMessagesResponse()) return
        for (pending in message.getPendingMessagesResponse.pendingMessagesList) {
            when (pending.messageType) {
                "AskQuestion" -> if (pending.hasAskQuestionRequest()) {
                    val req = pending.askQuestionRequest
                    val questions =
                        req.request.questionsList.joinToString("\n") { it.question }
                            .ifEmpty { "待处理的问题" }
                    NotificationHelper.notifyMessage(
                        this,
                        NotificationHelper.CHANNEL_QUESTIONS,
                        "待处理问题",
                        questions,
                        NotificationHelper.messageNotificationId("aq_${req.getID()}"),
                    )
                }
                "WorkReport" -> if (pending.hasWorkReportRequest()) {
                    val req = pending.workReportRequest
                    NotificationHelper.notifyMessage(
                        this,
                        NotificationHelper.CHANNEL_REPORTS,
                        "待确认汇报",
                        req.request.summary.ifEmpty { "待确认的工作汇报" },
                        NotificationHelper.messageNotificationId("wr_${req.getID()}"),
                    )
                }
            }
        }
    }

    private fun notifyChatMessage(message: WebsocketMessage) {
        if (!message.hasChatMessageNotification()) return
        val chat = message.chatMessageNotification.chatMessage
        val sender = chat.senderNickname.ifEmpty { chat.senderClientId }
        NotificationHelper.notifyMessage(
            this,
            NotificationHelper.CHANNEL_MESSAGES,
            sender,
            chat.content,
            NotificationHelper.messageNotificationId("chat_${chat.messageId}"),
        )
    }

    private fun notifyGenericReply(
        requestId: String,
        channel: String,
        keyPrefix: String,
        title: String,
    ) {
        if (requestId.isEmpty()) return
        NotificationHelper.notifyMessage(
            this,
            channel,
            title,
            "该请求已由其他用户处理",
            NotificationHelper.messageNotificationId("${keyPrefix}_$requestId"),
        )
    }
}

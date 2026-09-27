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

        /** 已完结请求的通知抑制窗口：覆盖一个心跳周期，防止在途 pending 回放重建通知 */
        private const val HANDLED_SUPPRESS_MS = 120_000L

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

    /** requestKey（aq_/wr_ 前缀 + requestId）→ 完结时间戳 */
    private val handledLock = Any()
    private val handledRequests = HashMap<String, Long>()

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
        val ok = conn.sendFrame(data)
        if (ok) dismissNotificationForOutboundFrame(data)
        return ok
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
            val message = try {
                WebsocketMessage.parseFrom(data)
            } catch (e: Exception) {
                return
            }
            // 引擎离线等同于不在前台：必须弹系统通知
            if (!AgentAssistantService.uiForeground || !clientAttached) {
                notifyForFrame(message)
            } else {
                // 前台不弹通知，但回复/取消类帧到达时仍要撤掉后台期间遗留的通知
                dismissNotificationForTerminalFrame(message)
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

    private fun notifyForFrame(message: WebsocketMessage) {
        when (message.cmd) {
            "AskQuestion" -> notifyAskQuestion(message)
            "WorkReport" -> notifyWorkReport(message)
            "GetPendingMessages" -> notifyPendingMessages(message)
            "ChatMessageNotification" -> notifyChatMessage(message)
            "AskQuestionReplyNotification" -> notifyHandledNotice(
                requestId = message.askQuestionRequest.getID(),
                channel = NotificationHelper.CHANNEL_QUESTIONS,
                keyPrefix = "aq",
                title = "问题已被回复",
            )
            "WorkReportReplyNotification" -> notifyHandledNotice(
                requestId = message.workReportRequest.getID(),
                channel = NotificationHelper.CHANNEL_REPORTS,
                keyPrefix = "wr",
                title = "汇报已被确认",
            )
            "RequestCancelled" -> notifyRequestCancelledNotice(message)
        }
    }

    /**
     * 完结类帧（回复广播/取消广播）：撤销通知栏里对应的待处理通知。
     * 只在 App 前台路径调用——后台时由 notifyForFrame 把同 id 通知
     * 更新成自动消失的「已处理」提示。
     */
    private fun dismissNotificationForTerminalFrame(message: WebsocketMessage) {
        when (message.cmd) {
            "AskQuestionReplyNotification" -> {
                val id = message.askQuestionRequest.getID()
                if (id.isNotEmpty()) markRequestHandled("aq_$id")
            }
            "WorkReportReplyNotification" -> {
                val id = message.workReportRequest.getID()
                if (id.isNotEmpty()) markRequestHandled("wr_$id")
            }
            "RequestCancelled" -> {
                val notification = message.requestCancelledNotification
                if (notification.requestId.isEmpty()) return
                when (notification.messageType) {
                    "WorkReport" -> markRequestHandled("wr_${notification.requestId}")
                    "AskQuestion" -> markRequestHandled("aq_${notification.requestId}")
                    else -> {
                        // 类型未知时两种前缀都撤，cancel 不存在的 id 无副作用
                        markRequestHandled("aq_${notification.requestId}")
                        markRequestHandled("wr_${notification.requestId}")
                    }
                }
            }
        }
    }

    /**
     * 本机发出的回复帧：回复广播不会回送本机，发送成功后直接撤销对应通知。
     */
    private fun dismissNotificationForOutboundFrame(data: ByteArray) {
        val message = try {
            WebsocketMessage.parseFrom(data)
        } catch (e: Exception) {
            return
        }
        val id = when (message.cmd) {
            "AskQuestionReply" -> message.askQuestionRequest.getID()
            "WorkReportReply" -> message.workReportRequest.getID()
            else -> return
        }
        if (id.isEmpty()) return
        val prefix = if (message.cmd == "AskQuestionReply") "aq" else "wr"
        markRequestHandled("${prefix}_$id")
    }

    /** 记录请求完结并撤销对应系统通知 */
    private fun markRequestHandled(requestKey: String) {
        recordHandled(requestKey)
        NotificationHelper.cancelMessage(this, requestKey)
    }

    /** 只记录完结时间，不动通知（后台路径的瞬态提示用它抑制 pending 回放） */
    private fun recordHandled(requestKey: String) {
        synchronized(handledLock) {
            handledRequests[requestKey] = System.currentTimeMillis()
        }
    }

    /** 请求是否刚刚完结：是则跳过重发/回放出的待处理通知 */
    private fun wasRecentlyHandled(requestKey: String): Boolean {
        val now = System.currentTimeMillis()
        synchronized(handledLock) {
            val it = handledRequests.entries.iterator()
            while (it.hasNext()) {
                if (now - it.next().value > HANDLED_SUPPRESS_MS) it.remove()
            }
            return handledRequests.containsKey(requestKey)
        }
    }

    private fun notifyAskQuestion(message: WebsocketMessage) {
        val req = message.askQuestionRequest
        val key = "aq_${req.getID()}"
        if (wasRecentlyHandled(key)) return
        val questions = req.request.questionsList.joinToString("\n") { it.question }
            .ifEmpty { "新的问题" }
        NotificationHelper.notifyMessage(
            this,
            NotificationHelper.CHANNEL_QUESTIONS,
            "新问题",
            questions,
            NotificationHelper.messageNotificationId(key),
        )
    }

    private fun notifyWorkReport(message: WebsocketMessage) {
        val req = message.workReportRequest
        val key = "wr_${req.getID()}"
        if (wasRecentlyHandled(key)) return
        NotificationHelper.notifyMessage(
            this,
            NotificationHelper.CHANNEL_REPORTS,
            "新工作汇报",
            req.request.summary.ifEmpty { "新的工作汇报" },
            NotificationHelper.messageNotificationId(key),
        )
    }

    private fun notifyPendingMessages(message: WebsocketMessage) {
        if (!message.hasGetPendingMessagesResponse()) return
        for (pending in message.getPendingMessagesResponse.pendingMessagesList) {
            when (pending.messageType) {
                "AskQuestion" -> if (pending.hasAskQuestionRequest()) {
                    val req = pending.askQuestionRequest
                    val key = "aq_${req.getID()}"
                    if (!wasRecentlyHandled(key)) {
                        val questions =
                            req.request.questionsList.joinToString("\n") { it.question }
                                .ifEmpty { "待处理的问题" }
                        NotificationHelper.notifyMessage(
                            this,
                            NotificationHelper.CHANNEL_QUESTIONS,
                            "待处理问题",
                            questions,
                            NotificationHelper.messageNotificationId(key),
                        )
                    }
                }
                "WorkReport" -> if (pending.hasWorkReportRequest()) {
                    val req = pending.workReportRequest
                    val key = "wr_${req.getID()}"
                    if (!wasRecentlyHandled(key)) {
                        NotificationHelper.notifyMessage(
                            this,
                            NotificationHelper.CHANNEL_REPORTS,
                            "待确认汇报",
                            req.request.summary.ifEmpty { "待确认的工作汇报" },
                            NotificationHelper.messageNotificationId(key),
                        )
                    }
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

    /**
     * 「已处理」瞬态提示：用同一 id 覆盖待处理通知（onlyAlertOnce 不重复响铃），
     * 超时后自动消失，避免已完结的请求一直留在通知栏。
     */
    private fun notifyHandledNotice(
        requestId: String,
        channel: String,
        keyPrefix: String,
        title: String,
    ) {
        if (requestId.isEmpty()) return
        recordHandled("${keyPrefix}_$requestId")
        NotificationHelper.notifyMessage(
            this,
            channel,
            title,
            "该请求已处理，无需回复",
            NotificationHelper.messageNotificationId("${keyPrefix}_$requestId"),
            timeoutAfterMs = NotificationHelper.HANDLED_NOTICE_TIMEOUT_MS,
        )
    }

    /** 请求取消广播：同样转成自动消失的瞬态提示 */
    private fun notifyRequestCancelledNotice(message: WebsocketMessage) {
        val notification = message.requestCancelledNotification
        if (notification.requestId.isEmpty()) return
        val channel: String
        val keyPrefix: String
        val title: String
        when (notification.messageType) {
            "WorkReport" -> {
                channel = NotificationHelper.CHANNEL_REPORTS
                keyPrefix = "wr"
                title = "汇报已取消"
            }
            "AskQuestion" -> {
                channel = NotificationHelper.CHANNEL_QUESTIONS
                keyPrefix = "aq"
                title = "问题已取消"
            }
            else -> {
                // 类型未知：先把两种前缀的通知都撤掉，提示走通用消息渠道
                markRequestHandled("aq_${notification.requestId}")
                markRequestHandled("wr_${notification.requestId}")
                channel = NotificationHelper.CHANNEL_MESSAGES
                keyPrefix = "rc"
                title = "请求已取消"
            }
        }
        recordHandled("${keyPrefix}_${notification.requestId}")
        NotificationHelper.notifyMessage(
            this,
            channel,
            title,
            notification.reason.ifEmpty { "该请求已取消" },
            NotificationHelper.messageNotificationId("${keyPrefix}_${notification.requestId}"),
            timeoutAfterMs = NotificationHelper.HANDLED_NOTICE_TIMEOUT_MS,
        )
    }
}

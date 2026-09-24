package code.agentassistant.flutter.flutterclient

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Dart ↔ AgentAssistantService 的桥。
 *
 * MethodChannel `agentassistant/ws`：连接管理、发帧、设置
 * EventChannel  `agentassistant/ws_events`：帧与状态事件推送给 Dart
 *
 * Dart 引擎在线时通过绑定拿到 Service 直接调用；
 * 引擎死亡时 Service 继续运行，缓冲的帧在下次附着时回放。
 */
class AgentAssistantWsPlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {

    companion object {
        private const val TAG = "AgentAssistantWsPlugin"
        const val METHOD_CHANNEL = "agentassistant/ws"
        const val EVENT_CHANNEL = "agentassistant/ws_events"
    }

    private lateinit var context: Context
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private var service: AgentAssistantService? = null
    private var serviceBound = false
    private val mainHandler = Handler(Looper.getMainLooper())

    // ------------------------------------------------------------------
    // FlutterPlugin
    // ------------------------------------------------------------------

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        methodChannel?.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
        eventChannel?.setStreamHandler(this)
        bindService()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        service?.onClientDetached()
        AgentAssistantService.eventSink = null
        eventChannel?.setStreamHandler(null)
        methodChannel?.setMethodCallHandler(null)
        eventChannel = null
        methodChannel = null
        eventSink = null
        if (serviceBound) {
            context.unbindService(serviceConnection)
            serviceBound = false
        }
        service = null
    }

    // ------------------------------------------------------------------
    // Service 绑定
    // ------------------------------------------------------------------

    private fun bindService() {
        val intent = Intent(context, AgentAssistantService::class.java)
        serviceBound = context.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)
    }

    private fun ensureServiceStarted() {
        val intent = Intent(context, AgentAssistantService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }
        if (!serviceBound) {
            serviceBound = context.bindService(
                intent, serviceConnection, Context.BIND_AUTO_CREATE,
            )
        }
    }

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
            val local = binder as? AgentAssistantService.LocalBinder ?: return
            service = local.getService()
            Log.i(TAG, "service connected")
            maybeAttachClient()
            flushPendingCalls()
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            service = null
            // 服务自停（stopSelf）后标记清除，下次 connect 时重新绑定
            serviceBound = false
        }
    }

    /** Service 绑定 + EventSink 就绪后，把事件流接到 Service 并回放缓冲 */
    private fun maybeAttachClient() {
        val svc = service ?: return
        val sink = eventSink ?: return
        AgentAssistantService.eventSink = { event ->
            mainHandler.post { sink.success(event) }
        }
        svc.onClientAttached()
    }

    // ------------------------------------------------------------------
    // EventChannel.StreamHandler
    // ------------------------------------------------------------------

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        maybeAttachClient()
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        AgentAssistantService.eventSink = null
        service?.onClientDetached()
    }

    // ------------------------------------------------------------------
    // MethodChannel
    // ------------------------------------------------------------------

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "connect" -> {
                ensureServiceStarted()
                val svc = service
                if (svc == null) {
                    // 绑定是异步的，连接指令延迟到绑定成功后执行
                    pendingCalls.add { s -> s.connect(
                        call.argument<String>("serverId")!!,
                        call.argument<String>("url")!!,
                        call.argument<String>("token")!!,
                        call.argument<String>("nickname") ?: "",
                    ) }
                    result.success(null)
                    return
                }
                svc.connect(
                    call.argument<String>("serverId")!!,
                    call.argument<String>("url")!!,
                    call.argument<String>("token")!!,
                    call.argument<String>("nickname") ?: "",
                )
                result.success(null)
            }
            "disconnect" -> {
                call.argument<String>("serverId")?.let { service?.disconnect(it) }
                result.success(null)
            }
            "disconnectAll" -> {
                service?.disconnectAll()
                result.success(null)
            }
            "reconnect" -> {
                call.argument<String>("serverId")?.let { service?.reconnect(it) }
                result.success(null)
            }
            "sendFrame" -> {
                val serverId = call.argument<String>("serverId")
                val data = call.argument<ByteArray>("data")
                val ok = if (serverId != null && data != null) {
                    service?.sendFrame(serverId, data) ?: false
                } else {
                    false
                }
                result.success(ok)
            }
            "updateNickname" -> {
                call.argument<String>("nickname")?.let { service?.updateNickname(it) }
                result.success(null)
            }
            "setUiForeground" -> {
                // companion 级标志，Service 未启动时也生效
                AgentAssistantService.uiForeground =
                    call.argument<Boolean>("foreground") ?: true
                result.success(null)
            }
            "isIgnoringBatteryOptimizations" -> {
                result.success(isIgnoringBatteryOptimizations())
            }
            "requestIgnoreBatteryOptimizations" -> {
                result.success(requestIgnoreBatteryOptimizations())
            }
            "openAppSettings" -> {
                result.success(openAppSettings())
            }
            else -> result.notImplemented()
        }
    }

    /** 绑定完成前到达的 connect 指令，绑定后统一执行 */
    private val pendingCalls = ArrayList<(AgentAssistantService) -> Unit>()

    private fun flushPendingCalls() {
        val svc = service ?: return
        for (call in pendingCalls) call(svc)
        pendingCalls.clear()
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(context.packageName)
    }

    private fun requestIgnoreBatteryOptimizations(): Boolean {
        return try {
            val intent = Intent(
                Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                Uri.parse("package:${context.packageName}"),
            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            true
        } catch (e: Exception) {
            Log.w(TAG, "requestIgnoreBatteryOptimizations failed", e)
            false
        }
    }

    private fun openAppSettings(): Boolean {
        return try {
            val intent = Intent(
                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.parse("package:${context.packageName}"),
            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            true
        } catch (e: Exception) {
            Log.w(TAG, "openAppSettings failed", e)
            false
        }
    }
}

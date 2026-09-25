package code.agentassistant.flutter.flutterclient

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build

/**
 * 前台服务与消息通知的统一管理。
 * - 常驻通知：服务存活期间显示连接状态
 * - 消息通知：收到 AskQuestion / WorkReport / ChatMessage 时弹出
 */
object NotificationHelper {

    const val CHANNEL_SERVICE = "aa_service"
    const val CHANNEL_QUESTIONS = "aa_questions"
    const val CHANNEL_REPORTS = "aa_reports"
    const val CHANNEL_MESSAGES = "aa_messages"

    const val SERVICE_NOTIFICATION_ID = 1000
    private const val MESSAGE_NOTIFICATION_BASE_ID = 2000

    fun ensureChannels(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = context.getSystemService(NotificationManager::class.java) ?: return

        // 常驻服务通知：低重要性、无声音
        nm.createNotificationChannel(
            NotificationChannel(
                CHANNEL_SERVICE,
                "后台连接服务",
                NotificationManager.IMPORTANCE_MIN,
            ).apply {
                description = "Agent Assistant 保持服务器连接时显示的常驻通知"
                setShowBadge(false)
            },
        )

        // 新问题通知：question.wav 提示音
        nm.createNotificationChannel(
            NotificationChannel(
                CHANNEL_QUESTIONS,
                "新问题",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "AI 代理发来新的提问"
                setSound(
                    resourceSoundUri(context, "question"),
                    messageAudioAttributes(),
                )
            },
        )

        // 工作汇报通知：report.wav 提示音
        nm.createNotificationChannel(
            NotificationChannel(
                CHANNEL_REPORTS,
                "工作汇报",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "AI 代理发来新的工作汇报"
                setSound(
                    resourceSoundUri(context, "report"),
                    messageAudioAttributes(),
                )
            },
        )

        // 普通消息通知：系统默认提示音
        nm.createNotificationChannel(
            NotificationChannel(
                CHANNEL_MESSAGES,
                "聊天消息",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "其他用户发来的聊天消息及回复通知"
            },
        )
    }

    private fun resourceSoundUri(context: Context, name: String): Uri {
        return Uri.parse("android.resource://${context.packageName}/raw/$name")
    }

    /** 与通知渠道声音保持一致（API < 26 无渠道机制时用） */
    private fun channelMessageSound(context: Context, channel: String): Uri {
        return when (channel) {
            CHANNEL_QUESTIONS -> resourceSoundUri(context, "question")
            CHANNEL_REPORTS -> resourceSoundUri(context, "report")
            else -> android.provider.Settings.System.DEFAULT_NOTIFICATION_URI
        }
    }

    private fun messageAudioAttributes(): AudioAttributes {
        return AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
    }

    /** 点击通知时回到 App 主界面 */
    private fun launchPendingIntent(context: Context, extra: Map<String, String>): PendingIntent {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent()
        intent.apply {
            setPackage(context.packageName)
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            for ((k, v) in extra) putExtra(k, v)
        }
        return PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    /** 常驻服务通知（显示当前连接状态） */
    fun buildServiceNotification(context: Context, contentText: String): Notification {
        ensureChannels(context)
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_SERVICE)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }
        return builder
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle("Agent Assistant")
            .setContentText(contentText)
            .setContentIntent(launchPendingIntent(context, emptyMap()))
            .setOngoing(true)
            .setCategory(Notification.CATEGORY_SERVICE)
            .build()
    }

    /** 弹一条消息通知 */
    fun notifyMessage(
        context: Context,
        channel: String,
        title: String,
        body: String,
        notificationId: Int,
        extras: Map<String, String> = emptyMap(),
    ) {
        ensureChannels(context)
        val nm = context.getSystemService(NotificationManager::class.java) ?: return
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, channel)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
                // 无通知渠道的旧系统：声音只能在通知本身上设置
                .setSound(channelMessageSound(context, channel))
        }
        val notification = builder
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(Notification.BigTextStyle().bigText(body))
            .setContentIntent(launchPendingIntent(context, extras))
            .setAutoCancel(true)
            .setOnlyAlertOnce(true) // 同 id 更新不再响铃（心跳重复带 pending 时防抖）
            .setCategory(Notification.CATEGORY_MESSAGE)
            .build()
        nm.notify(notificationId, notification)
    }

    /** 为每条消息生成稳定的通知 id（同一请求重复通知时替换） */
    fun messageNotificationId(requestKey: String): Int {
        return MESSAGE_NOTIFICATION_BASE_ID + (requestKey.hashCode() and 0x0FFF)
    }
}

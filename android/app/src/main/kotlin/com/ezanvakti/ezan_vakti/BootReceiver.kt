package com.ezanvakti.ezan_vakti

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import androidx.core.app.NotificationCompat

/**
 * BootReceiver restores the persistent prayer-time notification after device
 * reboot.  It reads SharedPreferences (written by Flutter via
 * flutter_local_notifications / SharedPreferences) to recover the next-prayer
 * name and target timestamp, then posts an ongoing notification with a
 * count-down chronometer that the OS drives natively – no running service
 * needed.
 */
class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val CHANNEL_ID = "ezan_countdown_channel"
        private const val NOTIF_ID = 0
        // SharedPreferences written by HomeWidget (home_widget package)
        private const val HW_PREFS = "HomeWidgetPreferences"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != "android.intent.action.QUICKBOOT_POWERON"
        ) return

        // Check if persistent notification is enabled
        val appPrefs = context.getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE
        )
        val enabled = appPrefs.getBoolean("flutter.persistent_notification", true)
        if (!enabled) return

        // Read cached data from HomeWidget prefs
        val hwPrefs = context.getSharedPreferences(HW_PREFS, Context.MODE_PRIVATE)
        val nextPrayer = hwPrefs.getString("next_prayer", null) ?: return
        val targetMillis = hwPrefs.getLong("target_time_millis", 0L)
        if (targetMillis == 0L || targetMillis < System.currentTimeMillis()) return

        ensureChannel(context)

        val baseTime = SystemClock.elapsedRealtime() +
                (targetMillis - System.currentTimeMillis())

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("🕌 $nextPrayer")
            .setContentText("Sonraki vakte geri sayım...")
            .setOngoing(true)
            .setAutoCancel(false)
            .setUsesChronometer(true)
            .setChronometerCountDown(true)
            .setWhen(targetMillis)
            .setShowWhen(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setSilent(true)
            .build()

        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIF_ID, notification)
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (nm.getNotificationChannel(CHANNEL_ID) == null) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "Vakit Sayacı",
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "Bildirim çubuğunda sabit namaz vakitleri gösterimi"
                    setShowBadge(false)
                    enableVibration(false)
                    setSound(null, null)
                }
                nm.createNotificationChannel(channel)
            }
        }
    }
}

package com.ezanvakti.ezan_vakti

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ezanvakti.ezan_vakti/notification"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "showCustomNotification") {
                val title = call.argument<String>("title") ?: "Ezan Vakti"
                val nextPrayer = call.argument<String>("nextPrayer") ?: "Yükleniyor..."
                val targetTimeMillis = call.argument<Long>("targetTimeMillis") ?: 0L
                val themeIndex = call.argument<Int>("themeIndex") ?: 0

                showCustomNotification(title, nextPrayer, targetTimeMillis, themeIndex)
                result.success(null)
            } else if (call.method == "cancelCustomNotification") {
                NotificationManagerCompat.from(this).cancel(0)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun showCustomNotification(title: String, nextPrayer: String, targetTimeMillis: Long, themeIndex: Int) {
        val channelId = "ezan_countdown_channel"

        // Ensure channel exists
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Vakit Sayacı"
            val descriptionText = "Bildirim çubuğunda sabit namaz vakitleri gösterimi"
            val importance = NotificationManager.IMPORTANCE_LOW
            val channel = NotificationChannel(channelId, name, importance).apply {
                description = descriptionText
                setSound(null, null)
                enableVibration(false)
                setShowBadge(false)
            }
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }

        val layoutId = when (themeIndex) {
            0 -> R.layout.prayer_widget_classic
            1 -> R.layout.prayer_widget_modern
            2 -> R.layout.prayer_widget_minimal
            else -> R.layout.prayer_widget
        }

        val remoteViews = RemoteViews(packageName, layoutId).apply {
            setTextViewText(R.id.tv_next_prayer, nextPrayer)
            if (targetTimeMillis > 0) {
                val baseTime = SystemClock.elapsedRealtime() + (targetTimeMillis - System.currentTimeMillis())
                setChronometer(R.id.tv_remaining_time, baseTime, null, true)
            }
        }

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent: PendingIntent = PendingIntent.getActivity(
            this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(remoteViews)
            .setCustomBigContentView(remoteViews)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pendingIntent)

        with(NotificationManagerCompat.from(this)) {
            // notificationId is 0 to match flutter_local_notifications persistent ID
            notify(0, builder.build())
        }
    }
}

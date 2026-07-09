package com.ezanvakti.ezan_vakti

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import android.os.SystemClock

class PrayerWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val themeIndex = widgetData.getInt("widget_theme_index", 0)
            val layoutId = when (themeIndex) {
                0 -> R.layout.prayer_widget_classic
                1 -> R.layout.prayer_widget_modern
                2 -> R.layout.prayer_widget_minimal
                else -> R.layout.prayer_widget
            }

            val views = RemoteViews(context.packageName, layoutId).apply {
                val nextPrayer = widgetData.getString("next_prayer", "Yükleniyor...")
                val targetTimeMillis = widgetData.getLong("target_time_millis", 0L)

                setTextViewText(R.id.tv_next_prayer, nextPrayer)
                
                if (targetTimeMillis > 0) {
                    val baseTime = SystemClock.elapsedRealtime() + (targetTimeMillis - System.currentTimeMillis())
                    setChronometer(R.id.tv_remaining_time, baseTime, null, true)
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

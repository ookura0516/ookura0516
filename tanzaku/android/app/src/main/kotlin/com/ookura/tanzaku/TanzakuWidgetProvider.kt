package com.ookura.tanzaku

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/**
 * 今日の季語と連続日数。アプリが翌日分も書いておくので、日本時間の0時を過ぎたら翌日分を出す。
 * タップで「詠む」を開く（tanzaku://compose）。
 */
class TanzakuWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val fmt = SimpleDateFormat("yyyy-MM-dd", Locale.US).apply {
            timeZone = TimeZone.getTimeZone("Asia/Tokyo")
        }
        val today = fmt.format(Date())
        val useTomorrow = widgetData.getString("tomorrow_date", null) == today
        val kigo = widgetData.getString(if (useTomorrow) "tomorrow_kigo" else "kigo", null) ?: "タンザク"
        val reading = widgetData.getString(if (useTomorrow) "tomorrow_reading" else "kigo_reading", null) ?: ""
        val season = widgetData.getString(if (useTomorrow) "tomorrow_season" else "season", null) ?: ""
        val streak = widgetData.getInt("streak", 0)
        // 日付が進んだら「今日詠んだか」は分からないので、前日に詠んでいれば連続日数だけ出す。
        val composedToday = !useTomorrow && widgetData.getBoolean("composed_today", false)

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.tanzaku_widget).apply {
                setTextViewText(R.id.widget_label, if (season.isEmpty()) "今日の兼題" else "今日の兼題・$season")
                setTextViewText(R.id.widget_kigo, kigo)
                setTextViewText(R.id.widget_reading, reading)
                setTextViewText(
                    R.id.widget_streak,
                    if (composedToday) "連続 $streak 日　✓" else "連続 $streak 日",
                )
                val intent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("tanzaku://compose"),
                )
                setOnClickPendingIntent(R.id.widget_root, intent)
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}

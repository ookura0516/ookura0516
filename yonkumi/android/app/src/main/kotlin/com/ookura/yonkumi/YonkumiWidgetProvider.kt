package com.ookura.yonkumi

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * ホーム画面ウィジェット。アプリ（ookura_daily の DailyWidgetSnapshot）が書いた
 * 今日と翌日の2日分から、切り替え時刻を過ぎていれば翌日分を出す。
 */
class YonkumiWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    val switchAt = widgetData.getString("ookura_daily.switch_at", null)?.toLongOrNull() ?: 0L
    val prefix =
        if (switchAt > 0 && System.currentTimeMillis() >= switchAt) "ookura_daily.tomorrow."
        else "ookura_daily.today."
    val title = widgetData.getString(prefix + "title", null) ?: "今日の問題"
    val status = widgetData.getString(prefix + "status", null) ?: "未解決"
    val done = widgetData.getString(prefix + "done", null) == "1"
    val streak = widgetData.getString(prefix + "streak", null)?.toIntOrNull() ?: 0

    appWidgetIds.forEach { id ->
      val views =
          RemoteViews(context.packageName, R.layout.yonkumi_widget).apply {
            setTextViewText(R.id.widget_title, title)
            setTextViewText(R.id.widget_status, status)
            setTextColor(R.id.widget_status, if (done) 0xFF75695E.toInt() else 0xFF9C3D2E.toInt())
            setTextViewText(R.id.widget_streak, if (streak > 0) "連続${streak}日" else "")
            setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
            )
          }
      appWidgetManager.updateAppWidget(id, views)
    }
  }
}

package com.ookura.kipputen

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/**
 * ホーム画面ウィジェット（小）：今日の4桁と、解いたかどうか。
 *
 * アプリは今日と翌日の分を書いておく（lib/daily/widget_payload.dart）。
 * 描くたびに日本時間の今日のキーを引くので、アプリを開かないまま0時を過ぎても翌日の番号が出る。
 */
class KipputenWidgetProvider : HomeWidgetProvider() {
  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    val fmt = SimpleDateFormat("yyyyMMdd", Locale.US)
    fmt.timeZone = TimeZone.getTimeZone("Asia/Tokyo")
    val key = fmt.format(Date())
    val number = widgetData.getString("day_${key}_title", null)
    val done = widgetData.getString("day_${key}_done", "0") == "1"

    for (id in appWidgetIds) {
      val views = RemoteViews(context.packageName, R.layout.kipputen_widget)
      views.setTextViewText(R.id.widget_number, number?.toCharArray()?.joinToString(" ") ?: "- - - -")
      views.setTextViewText(
          R.id.widget_status,
          when {
            number == null -> "アプリを開いてください"
            done -> "✂ 入鋏済み"
            else -> "まだ解いていません"
          },
      )
      val launch = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
      views.setOnClickPendingIntent(R.id.widget_root, launch)
      appWidgetManager.updateAppWidget(id, views)
    }
  }
}

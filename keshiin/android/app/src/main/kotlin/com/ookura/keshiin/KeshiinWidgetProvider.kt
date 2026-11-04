package com.ookura.keshiin

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

/**
 * 今月のシートの埋まり具合と、今日の空欄。
 *
 * アプリは「今日の分（today_）」と「明日の分（next_）」を両方書いておく。
 * 0時を過ぎたらアプリを開かなくても明日の分に切り替わるよう、端末の日付で選ぶ。
 */
class KeshiinWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Calendar.getInstance().time)
        val prefix = if (widgetData.getString("next_date", null) == today) "next_" else "today_"
        val stale = widgetData.getString("${prefix}date", null) != today

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.keshiin_widget).apply {
                setTextViewText(R.id.widget_month, widgetData.getString("${prefix}month", "今月のシート"))
                setTextViewText(R.id.widget_count, widgetData.getString("${prefix}count", "—"))
                setTextViewText(R.id.widget_grid, widgetData.getString("${prefix}grid", ""))
                setTextViewText(
                    R.id.widget_status,
                    if (stale) "アプリを開くと更新します" else widgetData.getString("${prefix}status", ""),
                )
                // タップで写真の選択を直接開く。
                val open = HomeWidgetLaunchIntent.getActivity(
                    context, MainActivity::class.java, Uri.parse("keshiin://create"),
                )
                setOnClickPendingIntent(R.id.widget_root, open)
            }
            appWidgetManager.updateAppWidget(id, views)
        }
        scheduleMidnight(context)
    }

    /** 次の0時すぎに自分を更新する（正確でなくてよいので、権限の要らない set を使う）。 */
    private fun scheduleMidnight(context: Context) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val next = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 1)
            set(Calendar.SECOND, 0)
        }
        val ids = AppWidgetManager.getInstance(context)
            .getAppWidgetIds(ComponentName(context, KeshiinWidgetProvider::class.java))
        val intent = Intent(context, KeshiinWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        }
        val pi = PendingIntent.getBroadcast(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        am.set(AlarmManager.RTC, next.timeInMillis, pi)
    }
}

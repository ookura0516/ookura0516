package com.ookura.nanakorobi

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File
import java.util.Calendar
import java.util.TimeZone

/**
 * ホーム画面の小ウィジェット（2×2。広げると縦長にもなる）。
 *
 * Flutter 側（lib/services/widget_sync.dart）が書き出した「だるまの絵（通常・転倒）」と
 * 日付の元データから、残り日数と転倒を「今日の日付」で計算して描く。Flutter を起動せずに
 * 0 時に進む。0 時の更新は home_widget の HomeWidgetScheduler（AlarmManager）で 14 日分を
 * 予約し、30 分ごとの updatePeriodMillis を保険にする。記録はアプリ内でだけ行う。
 */
class NanakorobiWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    for (id in appWidgetIds) {
      appWidgetManager.updateAppWidget(id, build(context, widgetData))
    }
  }

  private fun build(context: Context, data: SharedPreferences): RemoteViews {
    val views = RemoteViews(context.packageName, R.layout.nanakorobi_widget)
    val launch = Intent(context, MainActivity::class.java).apply {
      flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
    }
    views.setOnClickPendingIntent(
        R.id.widget_root,
        PendingIntent.getActivity(
            context, 0, launch, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE),
    )

    if (!data.getBoolean(KEY_HAS, false)) {
      views.setViewVisibility(R.id.widget_image, View.GONE)
      views.setViewVisibility(R.id.widget_done, View.GONE)
      views.setTextViewText(R.id.widget_days, context.getString(R.string.widget_empty))
      views.setTextViewText(R.id.widget_label, context.getString(R.string.widget_label))
      return views
    }

    val today = todayEpochDay()
    val deadline = data.num(KEY_DEADLINE) ?: -1L
    val created = data.num(KEY_CREATED) ?: today
    val lastStep = data.num(KEY_LAST_STEP) ?: -1L
    val anchor = if (lastStep >= 0) lastStep else created
    // 最後に記録した日（なければ開眼日）が昨日より前なら転倒（lib/core/rules.dart と同じ）。
    val fallen = today - anchor > 1
    val label = data.getString(KEY_LABEL, "") ?: ""
    val name = data.getString(KEY_NAME, "") ?: ""

    if (deadline >= 0) {
      val left = deadline - today
      views.setTextViewText(
          R.id.widget_days,
          when {
            left > 0 -> context.getString(R.string.widget_days_left, left)
            left == 0L -> context.getString(R.string.widget_today)
            else -> context.getString(R.string.widget_days_passed, -left)
          },
      )
      views.setTextViewText(
          R.id.widget_label,
          if (label.isEmpty()) context.getString(R.string.widget_default_label) else label,
      )
    } else {
      views.setTextViewText(R.id.widget_days, name)
      views.setTextViewText(R.id.widget_label, context.getString(R.string.widget_day_n, today - created + 1))
    }
    views.setViewVisibility(R.id.widget_done, if (lastStep == today) View.VISIBLE else View.GONE)

    val bitmap = data.getString(if (fallen) KEY_IMAGE_FALLEN else KEY_IMAGE_UP, null)?.let { decode(it) }
    if (bitmap != null) {
      views.setViewVisibility(R.id.widget_image, View.VISIBLE)
      views.setImageViewBitmap(R.id.widget_image, bitmap)
    } else {
      views.setViewVisibility(R.id.widget_image, View.GONE)
    }
    return views
  }

  /** 端末のローカル日付の epoch day（Flutter 側の LocalDate.epochDay と同じ数）。 */
  private fun todayEpochDay(): Long {
    val local = Calendar.getInstance()
    val utc = Calendar.getInstance(TimeZone.getTimeZone("UTC"))
    utc.clear()
    utc.set(local.get(Calendar.YEAR), local.get(Calendar.MONTH), local.get(Calendar.DAY_OF_MONTH))
    return utc.timeInMillis / 86_400_000L
  }

  /** 600×760 の PNG を半分に縮めて読む（RemoteViews の大きさの上限を避ける）。 */
  private fun decode(path: String): Bitmap? =
      try {
        if (!File(path).exists()) null
        else BitmapFactory.decodeFile(path, BitmapFactory.Options().apply { inSampleSize = 2 })
      } catch (e: Exception) {
        null
      }

  private fun SharedPreferences.num(key: String): Long? =
      when (val v = all[key]) {
        is Int -> v.toLong()
        is Long -> v
        is Float -> v.toLong()
        is Double -> v.toLong()
        else -> null
      }

  companion object {
    // lib/services/widget_sync.dart のキーと同じ。
    const val KEY_HAS = "nk_has"
    const val KEY_NAME = "nk_name"
    const val KEY_LABEL = "nk_label"
    const val KEY_DEADLINE = "nk_deadline"
    const val KEY_CREATED = "nk_created"
    const val KEY_LAST_STEP = "nk_last_step"
    const val KEY_IMAGE_UP = "nk_img_up"
    const val KEY_IMAGE_FALLEN = "nk_img_fallen"
  }
}

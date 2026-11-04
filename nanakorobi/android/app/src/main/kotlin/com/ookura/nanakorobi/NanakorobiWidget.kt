package com.ookura.nanakorobi

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalContext
import androidx.glance.LocalSize
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import org.json.JSONObject
import java.time.LocalDate

/**
 * ナナコロビのウィジェット（Glance）。小（2×2）と中（4×2）。
 *
 * アプリが SharedPreferences（HomeWidgetPreferences）のキー nanakorobi_snapshot に書いた JSON を読む。
 * 14 日分のタイムラインから「今日」の行を選ぶので、描き直しが遅れても日数は狂わない。記録はしない。
 */
class NanakorobiWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override val sizeMode = SizeMode.Responsive(setOf(SMALL, MEDIUM))

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val prefs = currentState<HomeWidgetGlanceState>().preferences
            Content(prefs.getString(KEY, null))
        }
    }

    @Composable
    private fun Content(json: String?) {
        val context = LocalContext.current
        val size = LocalSize.current
        val snapshot = Snapshot.parse(json)
        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(ColorProvider(PAPER))
                .cornerRadius(16.dp)
                .clickable(actionStartActivity<MainActivity>())
                .padding(10.dp),
            contentAlignment = Alignment.Center,
        ) {
            if (snapshot == null) {
                Text(context.getString(R.string.widget_empty), style = TextStyle(color = ColorProvider(INK_DIM), fontSize = 13.sp))
            } else if (size.width >= MEDIUM.width) {
                Medium(context, snapshot)
            } else {
                Small(context, snapshot)
            }
        }
    }

    @Composable
    private fun Small(context: Context, s: Snapshot) {
        val day = s.today()
        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalAlignment = Alignment.CenterVertically) {
            Daruma(context, s, 72.dp, 90.dp)
            Spacer(GlanceModifier.height(2.dp))
            Text(
                if (day?.daysLeft != null) context.getString(R.string.widget_days_left, day.daysLeft)
                else context.getString(R.string.widget_strokes, s.look.strokes),
                style = TextStyle(color = ColorProvider(INK), fontSize = 12.sp, fontWeight = FontWeight.Bold),
            )
        }
    }

    @Composable
    private fun Medium(context: Context, s: Snapshot) {
        val day = s.today()
        Row(verticalAlignment = Alignment.CenterVertically) {
            Daruma(context, s, 92.dp, 115.dp)
            Spacer(GlanceModifier.width(12.dp))
            Column {
                Text(s.name, style = TextStyle(color = ColorProvider(INK), fontSize = 15.sp, fontWeight = FontWeight.Bold))
                val deadlineName = s.deadlineName
                if (day?.daysLeft != null && deadlineName != null) {
                    Text(
                        context.getString(R.string.widget_deadline, deadlineName, day.daysLeft),
                        style = TextStyle(color = ColorProvider(VERMILION), fontSize = 17.sp, fontWeight = FontWeight.Bold),
                    )
                }
                if (day?.nextWaypointName != null && day.nextWaypointDays != null) {
                    Text(
                        context.getString(R.string.widget_next, day.nextWaypointName, day.nextWaypointDays),
                        style = TextStyle(color = ColorProvider(INK_DIM), fontSize = 11.sp),
                    )
                }
                Text(
                    context.getString(R.string.widget_stats, s.look.strokes, s.look.goldLines),
                    style = TextStyle(color = ColorProvider(INK), fontSize = 11.sp),
                )
                if (s.look.fallen) {
                    Text(context.getString(R.string.widget_fallen), style = TextStyle(color = ColorProvider(INK_DIM), fontSize = 10.sp))
                }
            }
        }
    }

    @Composable
    private fun Daruma(context: Context, s: Snapshot, width: androidx.compose.ui.unit.Dp, height: androidx.compose.ui.unit.Dp) {
        val density = context.resources.displayMetrics.density
        val bitmap = DarumaBitmap.draw(
            context,
            s.look,
            (width.value * density).toInt().coerceAtLeast(1),
            (height.value * density).toInt().coerceAtLeast(1),
            dim = !s.isRecordedToday(),
        )
        Image(
            provider = ImageProvider(bitmap),
            contentDescription = s.name,
            modifier = GlanceModifier.size(width, height),
        )
    }

    companion object {
        const val KEY = "nanakorobi_snapshot"
        val SMALL = DpSize(110.dp, 110.dp)
        val MEDIUM = DpSize(250.dp, 110.dp)
        val PAPER = Color(0xFFF7F1E6)
        val INK = Color(0xFF2A2320)
        val INK_DIM = Color(0xFF7A6E66)
        val VERMILION = Color(0xFFC73E2E)
    }
}

/** アプリが書く JSON（WidgetSnapshot）。 */
class Snapshot(
    val look: Look,
    val name: String,
    val deadlineName: String?,
    val timeline: List<Day>,
    private val generatedDate: String?,
) {
    class Look(
        val text: String,
        val colorId: Int,
        val seed: Int,
        val strokes: Int,
        val goldLines: Int,
        val eyes: String,
        val firstEye: String,
        val fallen: Boolean,
        val recordedToday: Boolean,
    )

    class Day(val date: String, val daysLeft: Int?, val nextWaypointName: String?, val nextWaypointDays: Int?)

    /** 今日の行。今日が範囲の外なら、いちばん近い端。 */
    fun today(): Day? {
        if (timeline.isEmpty()) return null
        val today = LocalDate.now().toString()
        timeline.firstOrNull { it.date == today }?.let { return it }
        return if (today < timeline.first().date) timeline.first() else timeline.last()
    }

    /** アプリが書いた日と今日が同じときだけ、今日の記録の有無が分かる。 */
    fun isRecordedToday(): Boolean = look.recordedToday && generatedDate == LocalDate.now().toString()

    companion object {
        fun parse(json: String?): Snapshot? {
            if (json.isNullOrEmpty()) return null
            return try {
                val root = JSONObject(json)
                val l = root.getJSONObject("look")
                val look = Look(
                    text = l.optString("text", ""),
                    colorId = l.optInt("color_id", 0),
                    seed = l.optInt("seed", 1),
                    strokes = l.optInt("strokes", 0),
                    goldLines = l.optInt("gold_lines", 0),
                    eyes = l.optString("eyes", "one"),
                    firstEye = l.optString("first_eye", "left"),
                    fallen = l.optBoolean("fallen", false),
                    recordedToday = l.optBoolean("recorded_today", false),
                )
                val days = ArrayList<Day>()
                val arr = root.optJSONArray("timeline")
                if (arr != null) {
                    for (i in 0 until arr.length()) {
                        val d = arr.getJSONObject(i)
                        days.add(
                            Day(
                                date = d.getString("date"),
                                daysLeft = if (d.isNull("daysLeft")) null else d.getInt("daysLeft"),
                                nextWaypointName = if (d.isNull("nextWaypointName")) null else d.getString("nextWaypointName"),
                                nextWaypointDays = if (d.isNull("nextWaypointDays")) null else d.getInt("nextWaypointDays"),
                            ),
                        )
                    }
                }
                val generated = root.optString("generated_at", "")
                Snapshot(
                    look = look,
                    name = root.optString("name", ""),
                    deadlineName = if (root.isNull("deadline_name")) null else root.optString("deadline_name"),
                    timeline = days,
                    generatedDate = if (generated.length >= 10) generated.substring(0, 10) else null,
                )
            } catch (_: Exception) {
                null
            }
        }
    }
}

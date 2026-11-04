package com.ookura.nanakorobi

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.DashPathEffect
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PathMeasure
import android.graphics.RectF
import android.graphics.Typeface
import kotlin.math.min

/**
 * ウィジェット用のだるま。アプリの DarumaPainter と同じ 100×125 の箱で描く簡略版
 * （体・顔・目・眉とひげの本数・腹の文字・腹の縁・台座の金の筋・転倒）。
 * 腹の文字は Flutter のアセットに入っている毛筆体（Yuji Syuku）を使う。
 */
object DarumaBitmap {
    private val BODIES = intArrayOf(
        0xFFC73E2E.toInt(), 0xFFF4EFE4.toInt(), 0xFF2B2A2E.toInt(), 0xFFE8B931.toInt(),
        0xFF3C8C5A.toInt(), 0xFF2F62A8.toInt(), 0xFF6E4A9E.toInt(), 0xFFE58AA5.toInt(),
        0xFFC9A227.toInt(), 0xFFE0762F.toInt(), 0xFF1F2A5C.toInt(), 0xFF7A4B2A.toInt(),
    )
    private val SHADES = intArrayOf(
        0xFF8F2418.toInt(), 0xFFB8AE9A.toInt(), 0xFF0F0E11.toInt(), 0xFFB38A17.toInt(),
        0xFF245A39.toInt(), 0xFF1C3F70.toInt(), 0xFF472C6B.toInt(), 0xFFB95C7A.toInt(),
        0xFF8F6F12.toInt(), 0xFFA3521B.toInt(), 0xFF111837.toInt(), 0xFF4E2E18.toInt(),
    )
    private val FACES = intArrayOf(
        0xFFF6E7C9.toInt(), 0xFFFBF7EE.toInt(), 0xFFF1E6CF.toInt(), 0xFFFBF3D6.toInt(),
        0xFFEAF2DD.toInt(), 0xFFE6EEF9.toInt(), 0xFFF0E8F7.toInt(), 0xFFFBEEF2.toInt(),
        0xFFFBF4D8.toInt(), 0xFFFBEBDD.toInt(), 0xFFE8EAF3.toInt(), 0xFFF3E7DA.toInt(),
    )
    private val LIGHT = setOf(1, 3, 7, 8)
    private const val GOLD = 0xFFC9A227.toInt()
    private const val GOLD_DARK = 0xFF9A7A14.toInt()
    private const val INK = 0xFF1B1A1E.toInt()
    private const val BASE = 0xFF3B2A1E.toInt()

    @Volatile
    private var brush: Typeface? = null

    private fun typeface(context: Context): Typeface {
        brush?.let { return it }
        val t = try {
            Typeface.createFromAsset(context.assets, "flutter_assets/assets/fonts/YujiSyuku-Regular.ttf")
        } catch (_: Exception) {
            Typeface.DEFAULT_BOLD
        }
        brush = t
        return t
    }

    fun draw(context: Context, look: Snapshot.Look, widthPx: Int, heightPx: Int, dim: Boolean): Bitmap {
        val bitmap = Bitmap.createBitmap(widthPx, heightPx, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val s = min(widthPx / 100f, heightPx / 125f)
        canvas.translate((widthPx - 100f * s) / 2f, (heightPx - 125f * s) / 2f)
        canvas.scale(s, s)

        val fill = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }
        val stroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeCap = Paint.Cap.ROUND
            strokeJoin = Paint.Join.ROUND
        }

        // 台座と金の筋
        fill.color = BASE
        canvas.drawRoundRect(RectF(20f, 108f, 80f, 121f), 4f, 4f, fill)
        val lines = min(look.goldLines, 10)
        if (lines > 0) {
            stroke.color = GOLD
            stroke.strokeWidth = 1.1f
            val gap = 56f / (lines + 1)
            for (i in 0 until lines) {
                val x = 22f + gap * (i + 1)
                canvas.drawLine(x, 112f, x, 119.5f, stroke)
            }
        }

        canvas.save()
        if (look.fallen) {
            canvas.translate(0f, 8f)
            canvas.rotate(if (look.firstEye == "left") 86f else -86f, 50f, 57f)
        }
        val alpha = if (dim) 150 else 255
        fill.alpha = alpha
        stroke.alpha = alpha

        val colorId = look.colorId.coerceIn(0, 11)
        val body = Path().apply {
            moveTo(50f, 6f)
            cubicTo(78f, 6f, 94f, 36f, 94f, 66f)
            cubicTo(94f, 86f, 86f, 104f, 72f, 108f)
            lineTo(28f, 108f)
            cubicTo(14f, 104f, 6f, 86f, 6f, 66f)
            cubicTo(6f, 36f, 22f, 6f, 50f, 6f)
            close()
        }
        fill.color = withAlpha(BODIES[colorId], alpha)
        canvas.drawPath(body, fill)
        stroke.color = withAlpha(SHADES[colorId], alpha)
        stroke.strokeWidth = 1.6f
        canvas.drawPath(body, stroke)
        if (look.strokes >= 100) {
            stroke.color = withAlpha(GOLD, alpha)
            stroke.strokeWidth = 2.2f
            canvas.drawPath(body, stroke)
        }

        val face = Path().apply {
            moveTo(50f, 17f)
            cubicTo(68f, 17f, 76f, 30f, 76f, 44f)
            cubicTo(76f, 60f, 66f, 70f, 50f, 72f)
            cubicTo(34f, 70f, 24f, 60f, 24f, 44f)
            cubicTo(24f, 30f, 32f, 17f, 50f, 17f)
            close()
        }
        fill.color = withAlpha(FACES[colorId], alpha)
        canvas.drawPath(face, fill)

        // 鼻と口
        stroke.color = withAlpha(INK, alpha)
        stroke.strokeWidth = 1.4f
        canvas.drawPath(Path().apply { moveTo(50f, 48f); quadTo(51.5f, 52f, 50f, 55f) }, stroke)
        stroke.strokeWidth = 1.5f
        canvas.drawPath(Path().apply { moveTo(45.5f, 60f); quadTo(50f, 62.5f, 54.5f, 60f) }, stroke)

        // 目：left はだるまの左目＝向かって右
        for ((side, x) in listOf("left" to 62f, "right" to 38f)) {
            val open = look.eyes == "both" || (look.eyes == "one" && look.firstEye == side)
            fill.color = withAlpha(Color.WHITE, alpha)
            canvas.drawCircle(x, 42f, 7.2f, fill)
            stroke.color = withAlpha(INK, if (open) alpha else alpha / 3)
            stroke.strokeWidth = if (open) 1.3f else 0.9f
            canvas.drawCircle(x, 42f, 7.2f, stroke)
            if (open) {
                fill.color = withAlpha(INK, alpha)
                canvas.drawCircle(x, 42f, 5f, fill)
            }
        }

        // 眉（最大 7 筆）
        stroke.color = withAlpha(INK, alpha)
        val brows = min(look.strokes, 7)
        for (i in 0 until brows) {
            val p = Path()
            if (i < 2) {
                val m = if (i == 0) -1f else 1f
                p.moveTo(50f + m * 8f, 34f)
                p.cubicTo(50f + m * 16f, 28f, 50f + m * 24f, 28f, 50f + m * 29f, 33f)
                stroke.strokeWidth = 2.6f
            } else {
                val k = i - 2
                val m = if (k % 2 == 0) -1f else 1f
                val n = (k / 2).toFloat()
                val x = 50f + m * (13f + n * 5.5f)
                val y = 30.5f - n * 0.6f
                p.moveTo(x, y)
                p.quadTo(x + m * 2.5f, y - 3.5f, x + m * 5.5f, y - 5.5f)
                stroke.strokeWidth = 1.8f
            }
            canvas.drawPath(p, stroke)
        }
        // ひげ（最大 14 筆）
        val beard = (look.strokes - 7).coerceIn(0, 14)
        stroke.strokeWidth = 1.8f
        for (i in 0 until beard) {
            val m = if (i % 2 == 0) -1f else 1f
            val n = (i / 2).toFloat()
            val sx = 50f + m * (7f + n * 0.9f)
            val sy = 50f + n * 2.4f
            val p = Path().apply {
                moveTo(sx, sy)
                quadTo(sx + m * 6f, sy - 1.5f, 50f + m * (15f + n * 2.4f), 55f + n * 3.0f)
            }
            canvas.drawPath(p, stroke)
        }

        // 腹の文字（縦書き）。50 筆で金。明るい体は濃い金。
        val chars = look.text.toCharArray()
        if (chars.isNotEmpty()) {
            val fontSize = when (chars.size) {
                1 -> 16f
                2 -> 13f
                3 -> 10.5f
                4 -> 8.5f
                else -> 7f
            }
            val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                typeface = typeface(context)
                textSize = fontSize
                textAlign = Paint.Align.CENTER
                color = withAlpha(
                    if (look.strokes >= 50) (if (colorId in LIGHT) GOLD_DARK else GOLD)
                    else (if (colorId in LIGHT) INK else 0xFFF7EFDF.toInt()),
                    alpha,
                )
            }
            val lineHeight = fontSize * 1.05f
            var y = 88f - lineHeight * chars.size / 2f
            for (ch in chars) {
                val baseline = y + lineHeight / 2f - (textPaint.ascent() + textPaint.descent()) / 2f
                canvas.drawText(ch.toString(), 50f, baseline, textPaint)
                y += lineHeight
            }
        }
        // 腹の縁（22〜50 筆目）
        val ringCount = (look.strokes - 21).coerceIn(0, 29)
        if (ringCount > 0) {
            val ring = Path().apply { addOval(RectF(33f, 68f, 67f, 108f), Path.Direction.CW) }
            val measure = PathMeasure(ring, false)
            val part = Path()
            measure.getSegment(0f, measure.length * ringCount / 29f, part, true)
            stroke.color = withAlpha(
                if (look.strokes >= 50) (if (colorId in LIGHT) GOLD_DARK else GOLD)
                else (if (colorId in LIGHT) SHADES[colorId] else 0xFFF3E8D2.toInt()),
                alpha,
            )
            stroke.strokeWidth = 1.5f
            stroke.pathEffect = DashPathEffect(floatArrayOf(3.4f, 1.6f), 0f)
            canvas.drawPath(part, stroke)
            stroke.pathEffect = null
        }
        canvas.restore()
        return bitmap
    }

    private fun withAlpha(color: Int, alpha: Int): Int = (color and 0x00FFFFFF) or (alpha.coerceIn(0, 255) shl 24)
}

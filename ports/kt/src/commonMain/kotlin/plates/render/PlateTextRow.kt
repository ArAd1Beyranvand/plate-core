package plates.render

import plates.core.alphabet.TextDirection
import plates.core.values.Rect
import kotlin.math.PI
import kotlin.math.min

/** StaggeredText timing: each character fades over charMs, the next starting stepMs later. */
const val STAGGER_CHAR_MS = 220.0
const val STAGGER_STEP_MS = 55.0

/**
 * [H24] The alpha of each UTF-16 unit of the incoming wording [ms] into its stagger,
 * indexed like Dart's String so a surrogate pair takes two steps.
 */
fun staggerAlphas(text: String, ms: Double): List<Double> =
    List(text.length) { ((ms - it * STAGGER_STEP_MS) / STAGGER_CHAR_MS).coerceIn(0.0, 1.0) }

/**
 * [D1] A label or other centred line of fixed text in [box]: scaled down to fit, never up;
 * [rotated] reads bottom to top.
 */
fun paintTextLine(
    c: DisplayList, text: String, box: Rect, style: TextStyle, direction: TextDirection,
    rotated: Boolean = false, align: TextAlign = TextAlign.center,
) {
    if (text.isEmpty()) return
    val w = measureText(text, style)
    val h = style.fontSize * style.height
    val fw = if (rotated) h else w
    val fh = if (rotated) w else h
    val k = min(1.0, min(box.width / fw, box.height / fh))
    c.save()
    c.translate((box.left + box.right) / 2, (box.top + box.bottom) / 2)
    c.scale(k)
    if (rotated) c.rotate(-PI / 2)
    c.text(text, Rect.fromLTWH(-w / 2, -h / 2, w, h), align, direction, style)
    c.restore()
}

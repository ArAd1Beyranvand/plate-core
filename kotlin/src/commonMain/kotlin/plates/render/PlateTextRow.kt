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
    rotated: Boolean = false, align: TextAlign = TextAlign.center, alphas: List<Double>? = null,
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
    c.text(text, Rect.fromLTWH(-w / 2, -h / 2, w, h), align, direction, style, alphas)
    c.restore()
}

/** [H24] A caption whose characters leave one after another, then the next wording's arrive. */
class StaggeredText(private var shown: String) {
    private var leaving = false
    private var at = 0.0

    var running = false
        private set

    private fun run(text: String) = STAGGER_CHAR_MS + STAGGER_STEP_MS * (text.length - 1).coerceIn(0, 99)

    /** What to paint for [value] at [now] (ms): the wording on show and, mid-stagger, each unit's alpha. */
    fun frame(value: String, now: Double): Pair<String, List<Double>?> {
        if (!leaving && value != shown) { leaving = true; running = true; at = now }
        if (leaving && now - at >= run(shown)) { shown = value; leaving = false; at = now }
        if (!leaving && running && now - at >= run(shown)) running = false
        if (!running) return shown to null
        val a = staggerAlphas(shown, now - at)
        return shown to if (leaving) a.map { 1 - it } else a
    }
}

package plates.render

import plates.core.alphabet.TextDirection
import plates.core.alphabet.splitRunes
import plates.core.values.Color
import plates.core.values.Rect
import kotlin.math.min

/** GlyphRun timing: a glyph grows in over enterMs and shrinks out over leaveMs. */
const val GLYPH_ENTER_MS = 260L
const val GLYPH_LEAVE_MS = 180L

private val marks = setOf(CharCategory.NON_SPACING_MARK, CharCategory.COMBINING_SPACING_MARK, CharCategory.ENCLOSING_MARK)
private val viramas = setOf(0x094D, 0x09CD, 0x0ACD, 0x0B4D, 0x0C4D, 0x0D4D)

private fun String.category() = if (length == 1) this[0].category else CharCategory.SURROGATE

/**
 * [H7] Grapheme clusters as Flutter's ICU splits a plate's text: a mark, a joiner's
 * follower, and a letter after an Indic virama (GB9c conjuncts) stay with the unit before.
 */
fun splitGraphemes(text: String): List<String> {
    val out = mutableListOf<String>()
    for (r in splitRunes(text)) {
        val prev = out.lastOrNull()?.let { splitRunes(it).last() }
        val joins = prev != null && (
            r.category() in marks || r == "\u200D" || prev == "\u200D" ||
                (prev[0].code in viramas && r[0].isLetter())
            )
        if (joins) out[out.size - 1] += r else out.add(r)
    }
    return out
}

/** [H7] The units a run animates: graphemes left to right; a right-to-left run stays whole so it keeps its shaping. */
fun glyphUnits(text: String, direction: TextDirection): List<String> = when {
    text.isEmpty() -> emptyList()
    direction == TextDirection.rtl -> listOf(text)
    else -> splitGraphemes(text)
}

private data class GlyphRun(val units: List<String>, val style: TextStyle, val widths: List<Double>, val skip: Int)

/**
 * [H12] PlateGlyphRun settled: one text op per unit, laid out along [box] from its start edge,
 * scaled down to fit and centred vertically at line height 1. A [caret] colour paints the insertion
 * point at the end of the typed text, where the run is.
 */
fun paintGlyphRun(
    c: DisplayList, text: String, box: Rect, style: TextStyle, direction: TextDirection,
    placeholder: Pair<String, Color>? = null, caret: Color? = null,
) {
    val rtl = direction == TextDirection.rtl
    // The characters already typed hide their twins; a whole right-to-left run is split at that point.
    val n = if (rtl) text.length else glyphUnits(text, direction).size
    val runs = listOfNotNull(
        placeholder?.takeIf { it.first.isNotEmpty() }?.let { Triple(it.first, style.copy(color = it.second), true) },
        Triple(text, style, false),
    ).map { (t, st, ghost) ->
        val units = if (ghost && rtl) listOf(t.take(n), t.drop(n)).filter { it.isNotEmpty() } else glyphUnits(t, direction)
        GlyphRun(units, st, units.map { measureText(it, st) }, if (!ghost) 0 else if (rtl) (if (n > 0) 1 else 0) else n)
    }.filter { it.units.isNotEmpty() }
    if (runs.isEmpty() && caret == null) return
    val total = runs.maxOfOrNull { it.widths.sum() } ?: 0.0
    val k = min(1.0, min(if (total > 0) box.width / total else 1.0, box.height / style.fontSize))
    val ltr = direction == TextDirection.ltr
    c.save()
    c.translate(box.left + (box.width - total * k) / 2, box.top + (box.height - style.fontSize * k) / 2)
    c.scale(k)
    for ((units, st, widths, skip) in runs) {
        var x = if (ltr) 0.0 else total
        for ((i, unit) in units.withIndex()) {
            if (!ltr) x -= widths[i]
            if (i >= skip) c.text(unit, Rect.fromLTWH(x, 0.0, widths[i], style.fontSize), TextAlign.start, direction, st)
            if (ltr) x += widths[i]
        }
    }
    if (caret != null) {
        val typed = runs.firstOrNull { it.skip == 0 && it.style === style }?.widths?.sum() ?: 0.0
        val x = if (ltr) typed else total - typed
        val f = style.fontSize
        c.rect(Rect.fromLTRB(x, f * 0.1, x + f * 0.05, f * 0.9), Paint(caret))
    }
    c.restore()
}

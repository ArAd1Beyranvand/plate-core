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

/**
 * [H12] PlateGlyphRun settled: one text op per unit, laid out along [box] from its start edge,
 * scaled down to fit and centred vertically at line height 1.
 */
fun paintGlyphRun(
    c: DisplayList, text: String, box: Rect, style: TextStyle, direction: TextDirection,
    placeholder: Pair<String, Color>? = null,
) {
    val runs = listOfNotNull(
        placeholder?.takeIf { it.first.isNotEmpty() }?.let { it.first to style.copy(color = it.second) },
        text to style,
    ).map { (t, st) -> Triple(glyphUnits(t, direction), st, glyphUnits(t, direction).map { measureText(it, st) }) }
        .filter { it.first.isNotEmpty() }
    if (runs.isEmpty()) return
    val total = runs.maxOf { it.third.sum() }
    val k = min(1.0, min(box.width / total, box.height / style.fontSize))
    val ltr = direction == TextDirection.ltr
    c.save()
    c.translate(box.left + (box.width - total * k) / 2, box.top + (box.height - style.fontSize * k) / 2)
    c.scale(k)
    for ((units, st, widths) in runs) {
        var x = if (ltr) 0.0 else total
        for ((i, unit) in units.withIndex()) {
            if (!ltr) x -= widths[i]
            c.text(unit, Rect.fromLTWH(x, 0.0, widths[i], style.fontSize), TextAlign.start, direction, st)
            if (ltr) x += widths[i]
        }
    }
    c.restore()
}

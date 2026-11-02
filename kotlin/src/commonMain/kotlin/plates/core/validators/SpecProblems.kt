package plates.core.validators

import plates.core.alphabet.PlateAlphabet
import plates.core.values.Axis
import plates.core.values.PlateBox
import plates.core.values.PlateFill
import plates.core.values.PlateSection
import plates.core.values.PlateSpec
import plates.core.values.Rect
import kotlin.math.abs

/**
 * Everything wrong with [spec], empty for a sound one: every rect fits the
 * canvas, every mirror echoes a real slot, registers are evenly pitched, and
 * alphabet ids key content one-to-one. Message texts are part of the vectors.
 */
fun specProblems(spec: PlateSpec<*>): List<String> {
    val problems = mutableListOf<String>()
    fun check(ok: Boolean, problem: () -> String) {
        if (!ok) problems.add(problem())
    }

    fun checkInCanvas(b: PlateBox, what: String) = check(
        b.left >= 0 && b.top >= 0 && b.right <= spec.canvasWidth && b.bottom <= spec.canvasHeight,
    ) { "$what in spec \"${spec.id}\" has a rect outside the canvas (${spec.canvasWidth}x${spec.canvasHeight})." }

    spec.slots.forEachIndexed { i, s -> checkInCanvas(s.box, "PlateSlot $i") }
    spec.mirrors.forEachIndexed { i, m ->
        checkInCanvas(m.box, "PlateMirror $i")
        check(m.source >= 0 && m.source < spec.slots.size) {
            "PlateMirror $i in spec \"${spec.id}\" echoes slot ${m.source}, which is " +
                "not a slot index (0..${spec.slots.size - 1})."
        }
    }
    spec.bands.forEachIndexed { i, b -> checkInCanvas(b.box, "PlateBand $i") }

    fun checkSection(s: PlateSection, r: Rect, path: String) {
        if (s is PlateSection.Leaf) {
            val fill = s.fill as? PlateFill.StripesFill ?: return
            val stripes = fill.stripes
            val stops = fill.stops
            check(stripes.size == stops.size + 1 && stripes.none { it is PlateFill.StripesFill }) {
                "Background leaf $path in spec \"${spec.id}\" has ${stripes.size} stripes " +
                    "and ${stops.size} stops; give one stop between each pair, and do not nest stripes."
            }
            for (i in 1 until stops.size) {
                check(stops[i] > stops[i - 1]) {
                    "Background leaf $path in spec \"${spec.id}\" has stops out of order: ${stops[i]} after ${stops[i - 1]}."
                }
            }
            return
        }
        s as PlateSection.Split
        val across = s.axis == Axis.horizontal
        var previous = if (across) r.left else r.top
        val end = if (across) r.right else r.bottom
        for ((i, part) in s.parts.withIndex()) {
            val last = i == s.parts.size - 1
            val partEnd0 = part.end
            check(if (last) partEnd0 == null else partEnd0 != null && partEnd0 > previous && partEnd0 < end) {
                "Background part $path.$i in spec \"${spec.id}\" ends at $partEnd0; " +
                    if (last) "the last part runs to its parent's end, so leave it null." else "expected a value in ($previous, $end)."
            }
            val partEnd = partEnd0 ?: end
            val child = if (across) Rect.fromLTRB(previous, r.top, partEnd, r.bottom)
            else Rect.fromLTRB(r.left, previous, r.right, partEnd)
            checkSection(part.section, child, "$path.$i")
            previous = partEnd
        }
    }
    checkSection(spec.background, Rect.fromLTWH(0.0, 0.0, spec.canvasWidth, spec.canvasHeight), "background")

    // Only keyed groups of three or more cells on one row have a pitch; a
    // register split across lines is exempt.
    for (g in spec.effectiveTextGroups) {
        if (g.key == null || g.indices.size < 3) continue
        val boxes = g.indices.mapNotNull { spec.slotAt(it)?.box }
        if (boxes.size != g.indices.size) continue
        if (!boxes.all { it.top == boxes[0].top && it.height == boxes[0].height }) continue
        val pitch = boxes[1].left - boxes[0].left
        for (n in 1 until boxes.size) {
            check(abs(boxes[n].left - boxes[0].left - n * pitch) < 0.01) {
                "Register \"${g.key}\" in spec \"${spec.id}\" is unevenly pitched: cell $n " +
                    "sits at ${boxes[n].left}, but a pitch of $pitch puts it at ${boxes[0].left + n * pitch}. " +
                    "Build it with plateRegister/plateRegisterAcross rather than cell by cell."
            }
        }
    }

    for (r in spec.restrictions) {
        check(spec.textGroups.any { it.key == r.group }) {
            "Restriction \"${r.reason}\" in spec \"${spec.id}\" watches group \"${r.group}\", " +
                "which no text group carries — it would never fire."
        }
    }

    // An alphabet id must map one-to-one onto rendered content, keyed by
    // characters and glyphs: national numerals share `latin.digits`' characters
    // but mean something else.
    val byId = mutableMapOf<String, String>()
    val byContent = mutableMapOf<String, String>()
    for (a in spec.slots.map { it.alphabet } + spec.mirrors.mapNotNull { it.alphabet }) {
        val contentKey = contentKey(a)
        val seenContent = byId[a.id]
        check(seenContent == null || seenContent == contentKey) {
            "Alphabet id \"${a.id}\" in spec \"${spec.id}\" appears with two different character/glyph sets."
        }
        byId[a.id] = contentKey
        val seenId = byContent[contentKey]
        check(seenId == null || seenId == a.id) {
            "Spec \"${spec.id}\" has two distinct alphabet ids (\"$seenId\", \"${a.id}\") sharing the same characters and glyphs."
        }
        byContent[contentKey] = a.id
    }
    return problems
}

private fun contentKey(a: PlateAlphabet) = a.characters.joinToString(" ") { "$it=${a.render(it)}" }

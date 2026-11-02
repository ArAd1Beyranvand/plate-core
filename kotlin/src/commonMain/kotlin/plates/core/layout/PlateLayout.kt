package plates.core.layout

import plates.core.alphabet.PlateAlphabet
import plates.core.values.Color
import plates.core.values.PlateBox
import plates.core.values.PlateMirror
import plates.core.values.PlateRule
import plates.core.values.PlateSlot

/** [count] equal cells from [left], stepping by [pitch] (default [width]: flush cells). */
fun plateRegister(
    alphabet: PlateAlphabet,
    count: Int,
    left: Double,
    top: Double,
    width: Double,
    height: Double,
    pitch: Double? = null,
    color: Color? = null,
): List<PlateSlot> {
    checkCount(count, "plateRegister")
    val step = pitch ?: width
    return List(count) { PlateSlot(alphabet, PlateBox(left + it * step, top, width, height), color) }
}

/** [count] flush cells filling `[left, right)` exactly. */
fun plateRegisterAcross(
    alphabet: PlateAlphabet,
    count: Int,
    left: Double,
    right: Double,
    top: Double,
    height: Double,
    color: Color? = null,
): List<PlateSlot> {
    checkCount(count, "plateRegisterAcross")
    val width = if (count == 0) 0.0 else (right - left) / count
    return plateRegister(alphabet, count, left, top, width, height, color = color)
}

/** One [PlateMirror] per entry of [sources], laid out as a register. */
fun plateEcho(
    sources: Iterable<Int>,
    left: Double,
    top: Double,
    width: Double,
    height: Double,
    pitch: Double? = null,
    glyphHeight: Double? = null,
    alphabet: PlateAlphabet? = null,
    editable: Boolean = false,
): List<PlateMirror> {
    val step = pitch ?: width
    return sources.mapIndexed { i, source ->
        PlateMirror(source, PlateBox(left + i * step, top, width, height), glyphHeight ?: height, alphabet, editable)
    }
}

/** [count] identical rules stepping by [stepX] across and [stepY] down. */
fun plateStipple(
    count: Int,
    left: Double,
    top: Double,
    width: Double,
    height: Double,
    stepX: Double = 0.0,
    stepY: Double = 0.0,
): List<PlateRule> {
    checkCount(count, "plateStipple")
    return List(count) { PlateRule(PlateBox(left + it * stepX, top + it * stepY, width, height)) }
}

private fun checkCount(count: Int, caller: String) = require(count >= 0) { "$caller needs count >= 0" }

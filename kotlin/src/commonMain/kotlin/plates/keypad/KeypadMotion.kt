package plates.keypad

import kotlin.math.ceil
import kotlin.math.max
import kotlin.math.roundToInt
import kotlin.math.sqrt
import plates.core.alphabet.AlphabetInput
import plates.core.alphabet.PlateAlphabet
import plates.core.timing.PlateCurves

/** Backspace's key label; not a character any alphabet accepts. */
const val kPlateBackspaceKey = "BACKSPACE"

/** [H11] Duration of a digits/letters switch in ms; the phase fractions below are fractions of it. */
const val kPlateKeypadSlide = 560L

/** Letters alphabet of a numeric-only keypad; never shown. */
val noLetters = PlateAlphabet.listed("keypad.noLetters", emptyList(), AlphabetInput.chosen, isNumeric = false)

private const val outEnd = 0.4
private const val resizeStart = 0.3
private const val resizeEnd = 0.7
private const val inStart = 0.6
const val swapAt = 0.5

val digitRows = listOf(listOf("1", "2", "3"), listOf("4", "5", "6"), listOf("7", "8", "9"), listOf("", "0", "⌫"))
val digitLabels = digitRows.flatten()
const val keyGap = 6.0
fun keyHeight(compact: Boolean) = if (compact) 44.0 else 56.0

private fun clamp01(x: Double) = x.coerceIn(0.0, 1.0)

/** [D1] How present key [index] of [count] is at [t]: 1 at rest, 0 while the grids swap. */
fun reveal(t: Double, index: Int, count: Int): Double {
    if (t >= 1.0) return 1.0
    val leaving = t < swapAt
    val a = if (leaving) 0.0 else inStart
    val b = if (leaving) outEnd else 1.0
    val start = if (count <= 1) 0.0 else index.toDouble() / (count - 1) * 0.5
    val p = clamp01(((t - a) / (b - a) - start) / 0.5)
    return if (leaving) 1.0 - PlateCurves.easeInCubic.transform(p) else PlateCurves.easeOutCubic.transform(p)
}

/** How present key [index] of [count] is [elapsed] ms into the pad coming in or going out: keys
 *  stagger over the first half of [kPlateKeypadSlide], in reading order coming in and reversed going out. */
fun entrance(elapsed: Double, index: Int, count: Int, coming: Boolean): Double {
    val at = if (count <= 1) 0.0 else (if (coming) index else count - 1 - index).toDouble() / (count - 1) * 0.5
    val p = clamp01((elapsed / kPlateKeypadSlide - at) / 0.5)
    return if (coming) PlateCurves.easeOutCubic.transform(p) else 1.0 - PlateCurves.easeInCubic.transform(p)
}

/** Pad height at [t] while resizing from [from] to [to]. */
fun heightAt(t: Double, from: Double, to: Double) =
    from + (to - from) * PlateCurves.easeInOutCubic.transform(clamp01((t - resizeStart) / (resizeEnd - resizeStart)))

/** [H17] A roughly square grid ending in backspace. */
data class KeyGrid(val id: String, val cells: List<String>, val columns: Int, val rows: Int)

private val grids = HashMap<String, KeyGrid>()

/** Cached by alphabet id (H3). */
fun gridFor(alphabet: PlateAlphabet): KeyGrid = grids.getOrPut(alphabet.id) {
    val letters = alphabet.characters
    val columns = max(1, ceil(sqrt(letters.size.toDouble())).toInt())
    val rows = ceil((letters.size + 1).toDouble() / columns).toInt()
    val cells = letters + List(max(0, rows * columns - letters.size - 1)) { "" } + "⌫"
    KeyGrid(alphabet.id, cells, columns, rows)
}

val digitGrid = KeyGrid("digits", digitLabels, digitRows[0].size, digitRows.size)

/** The pad height of a grid with [rows] rows. */
fun gridHeight(rows: Int, compact: Boolean) = rows * keyHeight(compact) + (rows - 1) * keyGap

/** What a key reports: backspace is its own key; a digit key reports the script it shows. */
fun reportedKey(label: String, digitAlphabet: PlateAlphabet?) =
    if (label == "⌫") kPlateBackspaceKey else digitAlphabet?.render(label) ?: label

/** The text on a key face. */
fun faceText(label: String, displayAlphabet: PlateAlphabet?) =
    if (label == "⌫" || displayAlphabet == null) label else displayAlphabet.render(label)

/** [H3] Whether [candidate] names [key] in either script. */
fun isHighlight(candidate: String?, key: String, digitAlphabet: PlateAlphabet? = null): Boolean {
    if (candidate == null) return false
    if (candidate == key) return true
    return digitAlphabet != null && digitAlphabet.canonical(candidate) == digitAlphabet.canonical(key)
}

/** Backspace always; otherwise only keys of the active (else the pad's own) alphabet. */
fun keyEnabled(key: String, own: PlateAlphabet, active: PlateAlphabet? = null) =
    key.isNotEmpty() && (key == kPlateBackspaceKey || (active ?: own).accepts(key))

/** [H14] Delay before key [index] of [count] turns grey (last to first) or returns (first to last). */
fun turnDelayMs(enabled: Boolean, index: Int, count: Int) = 18L * (if (enabled) count + index else count - 1 - index)

/** [H10] Colours are ARGB, like Flutter's. */
data class PlateKeypadTheme(
    val surface: Long = 0xFF1C1F26,
    val keyBorder: Long = 0x3DFFFFFF,
    val ink: Long = 0xFFFFFFFF,
    val disabledInk: Long = 0x4DFFFFFF,
    val highlight: Long = 0xFFE8A33D,
    val highlightInk: Long = 0xFF05080B,
)

fun cssColor(c: Long): String {
    val alpha = ((c shr 24) and 255) / 255.0
    val a = (alpha * 1000).roundToInt() / 1000.0
    return "rgba(${(c shr 16) and 255},${(c shr 8) and 255},${c and 255},${if (a == a.toLong().toDouble()) a.toLong().toString() else a.toString()})"
}

/** [H15] Each ARGB channel lerped on its own, rounded. */
fun lerpColor(a: Long, b: Long, t: Double): Long {
    var out = 0L
    for (shift in intArrayOf(24, 16, 8, 0)) {
        val x = ((a shr shift) and 255).toDouble()
        val y = ((b shr shift) and 255).toDouble()
        out = out or ((x + (y - x) * t).roundToInt().toLong() shl shift)
    }
    return out
}

const val flashInMs = 90L
const val flashOutMs = 160L
const val greyOutMs = 180L

/** [H15] A colour tween on the shared clock, easeOut, retargeted from where it is. */
class ColorTween(value: Long) {
    private var from = value
    private var to = value
    private var at = 0.0
    private var ms = 0L

    fun set(target: Long, now: Double, ms: Long) {
        if (target == to) return
        from = value(now)
        to = target
        at = now
        this.ms = ms
    }

    fun value(now: Double): Long {
        val t = if (ms <= 0) 1.0 else clamp01((now - at) / ms)
        return if (t >= 1.0) to else lerpColor(from, to, PlateCurves.easeOut.transform(t))
    }

    fun running(now: Double) = now - at < ms && from != to
}

/** The fill/border/ink targets and duration of a key face. */
data class FaceTargets(val fill: Long, val border: Long, val ink: Long, val ms: Long, val scale: Double)

fun faceTargets(theme: PlateKeypadTheme, highlighted: Boolean, enabled: Boolean): FaceTargets {
    val dim = (theme.keyBorder and 0xFFFFFF) or (((((theme.keyBorder shr 24) and 255) * 0.5).roundToInt().toLong()) shl 24)
    return FaceTargets(
        fill = if (highlighted) theme.highlight else 0,
        border = if (highlighted) theme.highlight else if (enabled) theme.keyBorder else dim,
        ink = if (highlighted) theme.highlightInk else if (enabled) theme.ink else theme.disabledInk,
        ms = if (highlighted) flashInMs else if (enabled) flashOutMs else greyOutMs,
        scale = if (highlighted) 0.94 else 1.0,
    )
}

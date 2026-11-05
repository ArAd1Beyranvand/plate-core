package plates.keypad

import plates.core.alphabet.PlateAlphabet
import plates.core.alphabet.TextDirection

data class PlateKeypadOptions(
    val digitAlphabet: PlateAlphabet,
    val letterAlphabet: PlateAlphabet? = null,
    val activeAlphabet: PlateAlphabet? = null,
    val showLetters: Boolean = false,
    val compact: Boolean = false,
    val theme: PlateKeypadTheme = PlateKeypadTheme(),
)

data class KeyCell(val label: String, val index: Int, val key: String, val text: String, val enabled: Boolean)

/** [D1] The switch state machine of the pad, headless: grids, heights and per-key presence at a time. */
class KeypadModel(var options: PlateKeypadOptions) {
    private var fromLetters = options.showLetters
    private var toLetters = options.showLetters
    private var fromHeight: Double? = null
    private var startedAt = Double.NEGATIVE_INFINITY
    private var enteredAt = Double.NEGATIVE_INFINITY
    private var coming = true

    val theme get() = options.theme
    val compact get() = options.compact
    val letterAlphabet get() = options.letterAlphabet ?: noLetters
    val direction get() = if (letterAlphabet.direction == TextDirection.rtl) "rtl" else "ltr"

    /** Animation position 0..1 at [now]. */
    fun t(now: Double) = ((now - startedAt) / kPlateKeypadSlide).coerceIn(0.0, 1.0)

    fun animating(now: Double) = t(now) < 1.0 || now - enteredAt < kPlateKeypadSlide

    /** Starts the whole pad staggering in ([coming]) or out from [now]. */
    fun enter(now: Double, coming: Boolean) {
        enteredAt = now
        this.coming = coming
    }

    /** Applies new options; a showLetters flip starts or reverses a switch. */
    fun update(o: PlateKeypadOptions, now: Double) {
        options = o
        if (o.showLetters == toLetters) return
        val t = t(now)
        if (t < swapAt) {
            fromLetters = toLetters.also { toLetters = fromLetters }
            fromHeight = null
            startedAt = now - (1 - t) * kPlateKeypadSlide
            return
        }
        fromHeight = if (t < 1.0) heightAt(now) else null
        fromLetters = toLetters
        toLetters = o.showLetters
        startedAt = now
    }

    private fun naturalHeight(letters: Boolean) =
        gridHeight(if (letters) gridFor(letterAlphabet).rows else digitRows.size, compact)

    fun heightAt(now: Double) = heightAt(t(now), fromHeight ?: naturalHeight(fromLetters), naturalHeight(toLetters))

    /** The grid on screen at [now]: before the swap the leaving one, after it the arriving one. */
    fun showingLetters(now: Double) = if (t(now) < swapAt) fromLetters else toLetters

    fun grid(letters: Boolean) = if (letters) gridFor(letterAlphabet) else digitGrid

    /** How present the pad itself is: it fades with its keys when it comes in or goes out. */
    fun padPresence(now: Double): Double {
        val p = ((now - enteredAt) / kPlateKeypadSlide).coerceIn(0.0, 1.0)
        return if (coming) p else 1 - p
    }

    fun presence(now: Double, index: Int, count: Int) = reveal(t(now), index, count) * entrance(now - enteredAt, index, count, coming)

    /** Alphabet that renders and reports keys of a grid: digits report in their script, letters verbatim. */
    fun digitsOf(letters: Boolean) = if (letters) null else options.digitAlphabet

    fun cells(letters: Boolean): List<KeyCell> {
        val own = if (letters) letterAlphabet else options.digitAlphabet
        val digits = digitsOf(letters)
        return grid(letters).cells.mapIndexed { index, label ->
            val key = reportedKey(label, digits)
            KeyCell(label, index, key, faceText(label, own), label != "" && keyEnabled(key, own, options.activeAlphabet))
        }
    }
}

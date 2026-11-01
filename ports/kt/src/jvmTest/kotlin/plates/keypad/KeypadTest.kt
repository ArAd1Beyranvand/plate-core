package plates.keypad

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import plates.core.alphabet.AlphabetInput
import plates.core.alphabet.PlateAlphabet
import plates.core.alphabet.PlateAlphabet.Companion.latinDigits
import plates.core.alphabet.PlateAlphabet.Companion.latinUppercase

class KeypadTest {
    private val persian = PlateAlphabet.listed(
        "fa.digits", "0123456789".map { it.toString() }, AlphabetInput.typed, true,
        glyphs = "0123456789".mapIndexed { i, c -> c.toString() to "۰۱۲۳۴۵۶۷۸۹"[i].toString() }.toMap(),
    )

    @Test
    fun revealIsOrdered() {
        assertEquals(1.0, reveal(1.0, 3, 12))
        assertEquals(0.0, reveal(0.5, 0, 12))
        assertTrue(reveal(0.2, 11, 12) > reveal(0.2, 0, 12))
        assertTrue(reveal(0.8, 0, 12) > reveal(0.8, 11, 12))
    }

    @Test
    fun gridIsSquareEndsInBackspaceAndCached() {
        val g = gridFor(latinUppercase)
        assertEquals(listOf(6, 5, 30), listOf(g.columns, g.rows, g.cells.size))
        assertEquals("⌫", g.cells.last())
        assertTrue(g === gridFor(latinUppercase))
    }

    @Test
    fun colours() {
        assertEquals("rgba(255,255,255,0.239)", cssColor(0x3DFFFFFF))
        assertEquals(0x80808080L, lerpColor(0xFF000000, 0x00FFFFFF, 0.5))
        val t = ColorTween(0)
        t.set(0xFF000000, 0.0, 100)
        assertEquals(0L, t.value(0.0))
        assertEquals(0xFF000000, t.value(100.0))
        assertEquals(90L, faceTargets(PlateKeypadTheme(), true, true).ms)
    }

    @Test
    fun highlightMatchesAcrossScripts() {
        assertTrue(isHighlight("5", "۵", persian))
        assertFalse(isHighlight("4", "۵", persian))
        assertFalse(isHighlight(null, "5"))
        assertEquals(18L * 11, turnDelayMs(false, 0, 12))
    }

    @Test
    fun digitsPadReportsShownScriptAndDisablesOutsideActive() {
        val only5 = PlateAlphabet.listed("one", listOf("5"), AlphabetInput.typed, true, glyphs = persian.glyphs)
        val cells = KeypadModel(PlateKeypadOptions(persian, activeAlphabet = only5)).cells(false)
        val five = cells.first { it.label == "5" }
        assertEquals(listOf("۵", "۵", true), listOf(five.key, five.text, five.enabled))
        assertFalse(cells.first { it.label == "4" }.enabled)
        assertEquals(kPlateBackspaceKey, cells.first { it.label == "⌫" }.key)
        assertTrue(cells.first { it.label == "⌫" }.enabled)
        assertFalse(cells.first { it.label == "" }.enabled)
    }

    @Test
    fun switchSwapsAtMidpointAndResizes() {
        val o = PlateKeypadOptions(latinDigits, latinUppercase)
        val m = KeypadModel(o)
        assertFalse(m.animating(0.0))
        m.update(o.copy(showLetters = true), 1000.0)
        assertTrue(m.animating(1000.0))
        assertFalse(m.showingLetters(1000.0 + kPlateKeypadSlide * 0.4))
        assertTrue(m.showingLetters(1000.0 + kPlateKeypadSlide * 0.6))
        assertTrue(m.heightAt(1000.0 + kPlateKeypadSlide) > m.heightAt(1000.0))
        assertFalse(m.animating(1000.0 + kPlateKeypadSlide))
    }

    @Test
    fun reversalBeforeSwapBringsOldGridBack() {
        val o = PlateKeypadOptions(latinDigits, latinUppercase)
        val m = KeypadModel(o)
        m.update(o.copy(showLetters = true), 0.0)
        m.update(o.copy(showLetters = false), kPlateKeypadSlide * 0.2)
        assertEquals(0.8, m.t(kPlateKeypadSlide * 0.2), 1e-9)
        assertFalse(m.showingLetters(kPlateKeypadSlide * 0.2))
    }

    @Test
    fun pickerListsCanonicalValuesWithGlyphs() {
        assertEquals(PickerItem("5", "۵"), pickerItems(persian)[5])
    }
}

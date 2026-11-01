package plates.core.layout

import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import plates.core.alphabet.PlateAlphabet
import plates.core.theme.PlateTheme
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength
import plates.core.validators.specProblems
import plates.core.values.PlateBox
import plates.core.values.PlateCountry
import plates.core.values.PlateRestrictionException
import plates.core.values.PlateSlot
import plates.core.values.PlateSpec
import plates.core.values.ValuesRestriction
import plates.loadVectors
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertTrue

class LayoutTest {
    private val digits = PlateAlphabet.latinDigits

    private fun box(b: PlateBox) = JsonArray(listOf(b.left, b.top, b.width, b.height, b.right, b.bottom).map(::JsonPrimitive))

    private fun build(i: JsonObject): JsonElement {
        fun d(k: String) = i[k]?.jsonPrimitive?.doubleOrNull ?: 0.0
        val count = i["count"]!!.jsonPrimitive.int
        val pitch = i["pitch"]?.jsonPrimitive?.doubleOrNull
        return when (i["builder"]!!.jsonPrimitive.content) {
            "plateRegister" -> JsonArray(plateRegister(digits, count, d("left"), d("top"), d("width"), d("height"), pitch).map { box(it.box) })
            "plateRegisterAcross" -> JsonArray(plateRegisterAcross(digits, count, d("left"), d("right"), d("top"), d("height")).map { box(it.box) })
            "plateEcho" -> JsonArray(
                plateEcho(i["sources"]!!.jsonArray.map { it.jsonPrimitive.int }, d("left"), d("top"), d("width"), d("height"), pitch).map {
                    JsonObject(mapOf("source" to JsonPrimitive(it.source), "box" to box(it.box), "glyphHeight" to JsonPrimitive(it.glyphHeight)))
                },
            )
            else -> JsonArray(plateStipple(count, d("left"), d("top"), d("width"), d("height"), d("stepX"), d("stepY")).map { box(it.box) })
        }
    }

    @Test
    fun builderVectors() {
        val cases = loadVectors("core/layout.json").filter { it.input.jsonObject.containsKey("builder") }
        assertTrue(cases.isNotEmpty())
        for (c in cases) {
            val expect = c.expect
            if (expect is JsonObject && expect.containsKey("throws")) {
                assertFailsWith<IllegalArgumentException>(c.name) { build(c.input.jsonObject) }
            } else {
                assertEquals(expect, build(c.input.jsonObject), c.name)
            }
        }
    }

    @Test
    fun digitsAreAsciiOnly() {
        assertTrue(isDigits("0129"))
        assertTrue(!isDigits("٣"))
        assertTrue(!isDigits(""))
        assertTrue(isDigitsOfLength("12", 2))
        assertTrue(!isDigitsOfLength("12", 3))
    }

    @Test
    fun restrictionException() {
        val e = PlateRestrictionException(ValuesRestriction("g", listOf("09"), "no 09"))
        assertEquals("no 09", e.message)
    }

    @Test
    fun themeEqualityAndLerp() {
        val a = PlateTheme.standard()
        assertEquals(a, a.copy())
        assertTrue(a != a.copy(ink = 1))
        val b = a.copy(plateBackground = 0xFF000000.toInt(), borderWidthRatio = 0.08)
        assertEquals(a, PlateTheme.lerp(a, b, 0.0))
        assertEquals(b, PlateTheme.lerp(a, b, 1.0))
        assertEquals(0xFF808080.toInt(), PlateTheme.lerp(a, b, 0.5).plateBackground)
        assertEquals(72.0, a.glyphStyle(100.0, 0).fontSize, 1e-9)
    }

    @Test
    fun specProblemsReported() {
        val slots = plateRegister(digits, 3, 0.0, 0.0, 10.0, 10.0)
        fun mk(s: List<PlateSlot>) = PlateSpec<Any>("t", PlateCountry("t", emptyList(), 0, null), 30.0, 10.0, null, s)
        assertEquals(emptyList(), specProblems(mk(slots)))
        assertEquals(
            listOf("PlateSlot 3 in spec \"t\" has a rect outside the canvas (30.0x10.0)."),
            specProblems(mk(slots + PlateSlot(digits, PlateBox(25.0, 0.0, 10.0, 10.0)))),
        )
    }
}

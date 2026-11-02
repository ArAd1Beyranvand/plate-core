package plates.core.alphabet

import java.io.File
import kotlinx.serialization.json.*
import plates.core.input.PlateInputSource
import plates.core.input.PlateMode
import plates.core.input.SlotBehavior
import plates.core.input.resolveSlotBehavior
import plates.core.values.*
import plates.loadVectors
import kotlin.test.Test
import kotlin.test.assertEquals

private val alphabets = Json.parseToJsonElement(
    File(System.getProperty("plates.vectors"), "../data/alphabets.json").readText(),
).jsonObject["alphabets"]!!.jsonObject

fun alphabetOf(ref: String): PlateAlphabet {
    val a = alphabets[ref]!!.jsonObject
    return PlateAlphabet.listed(
        id = a["id"]!!.jsonPrimitive.content,
        characters = a["characters"]!!.jsonArray.map { it.jsonPrimitive.content },
        input = AlphabetInput.valueOf(a["input"]!!.jsonPrimitive.content),
        isNumeric = a["isNumeric"]!!.jsonPrimitive.boolean,
        glyphs = a["glyphs"]!!.jsonArray.associate { it.jsonArray[0].jsonPrimitive.content to it.jsonArray[1].jsonPrimitive.content },
        direction = TextDirection.valueOf(a["direction"]!!.jsonPrimitive.content),
        placeholder = a["placeholder"]!!.jsonPrimitive.content,
    )
}

class AlphabetTest {
    @Test
    fun alphabetVectors() {
        for (c in loadVectors("core/alphabet.json")) {
            val i = c.input.jsonObject
            val e = c.expect.jsonObject
            if ("include" in i) {
                val a = PlateAlphabet.pattern(
                    "p", i["include"]!!.jsonPrimitive.content, i["exclude"]!!.jsonPrimitive.content,
                    AlphabetInput.typed, false,
                )
                assertEquals(e["characters"]!!.jsonArray.map { it.jsonPrimitive.content }, a.characters, c.name)
                continue
            }
            val a = alphabetOf(i["alphabet"]!!.jsonPrimitive.content)
            val v = i["value"]!!.jsonPrimitive.content
            assertEquals(e["accepts"]!!.jsonPrimitive.boolean, a.accepts(v), c.name)
            assertEquals(e["canonical"]!!.jsonPrimitive.content, a.canonical(v), c.name)
            assertEquals(e["render"]!!.jsonPrimitive.content, a.render(v), c.name)
            assertEquals(e["renderAll"]!!.jsonPrimitive.content, a.renderAll(v), c.name)
            assertEquals(e["canonicalAll"]!!.jsonPrimitive.content, a.canonicalAll(v), c.name)
        }
    }

    @Test
    fun slotVectors() {
        for (c in loadVectors("core/values.json").filter { it.name.startsWith("slot ") }) {
            val i = c.input.jsonObject
            val sl = i["slot"]!!.jsonObject
            val s = PlateSlot(
                alphabetOf(sl["alphabet"]!!.jsonPrimitive.content), PlateBox(0.0, 0.0, 1.0, 1.0),
                length = sl["length"]!!.jsonPrimitive.int, minLength = sl["minLength"]!!.jsonPrimitive.int,
            )
            val v = i["value"]!!.jsonPrimitive.contentOrNull
            val e = c.expect.jsonObject
            assertEquals(e["isFull"]!!.jsonPrimitive.boolean, s.isFull(v), c.name)
            assertEquals(e["isComplete"]!!.jsonPrimitive.boolean, s.isComplete(v), c.name)
            if (v != null) {
                assertEquals(e["accepts"]!!.jsonPrimitive.boolean, s.accepts(v), c.name)
                assertEquals(e["canonical"]!!.jsonPrimitive.content, s.canonical(v), c.name)
                assertEquals(e["render"]!!.jsonPrimitive.content, s.render(v), c.name)
            }
        }
    }

    @Test
    fun behaviorVectors() {
        for (c in loadVectors("core/input.json").filter { it.name.startsWith("behavior ") }) {
            val i = c.input.jsonObject
            val got = resolveSlotBehavior(
                PlateMode.valueOf(i["mode"]!!.jsonPrimitive.content),
                AlphabetInput.valueOf(i["input"]!!.jsonPrimitive.content),
                PlateInputSource.valueOf(i["source"]!!.jsonPrimitive.content),
            )
            assertEquals(SlotBehavior.valueOf(c.expect.jsonPrimitive.content), got, c.name)
        }
    }

    @Test
    fun surrogatePairsStayWhole() {
        assertEquals(listOf("a", "😀", "b"), splitRunes("a😀b"))
    }

    @Test
    fun sectionLayout() {
        val leaf = { n: Int -> PlateSection.Leaf(PlateFill.ColorFill(n)) }
        val root = PlateSection.Split(
            Axis.horizontal,
            listOf(PlatePart(leaf(1), 10.0, 2.0), PlatePart(PlateSection.Leaf(PlateFill.Field))),
        )
        val r = root.layout(Rect(0.0, 0.0, 30.0, 5.0))
        assertEquals(listOf(Rect(0.0, 0.0, 10.0, 5.0), Rect(10.0, 0.0, 30.0, 5.0)), r.leaves.map { it.second })
        assertEquals(listOf(Rect(9.0, 0.0, 11.0, 5.0)), r.dividers)
    }
}

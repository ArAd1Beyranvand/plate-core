package plates.core.input

import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.put
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.values.ValuesRestriction
import plates.loadVectors
import plates.specOf
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertSame
import kotlin.test.assertTrue

/** Stands in for the country validators, which later units port; its verdicts are not compared. */
private val unported = PlateValidator { PlateValidation.valid }

private fun JsonElement.strs() = jsonArray.map { it.jsonPrimitive.contentOrNull }

private fun state(c: PlateController, codeRegion: Boolean, judged: Boolean, withSession: Boolean = true) = buildJsonObject {
    put("values", kotlinx.serialization.json.JsonArray(c.values.map(::JsonPrimitive)))
    put("isCompleted", c.isCompleted)
    put("isEmpty", c.isEmpty)
    put("rejection", c.rejection.value?.reason)
    put("text", c.text())
    put("textJoined", c.text(""))
    if (!codeRegion) put("regionCaption", c.regionCaption)
    if (!withSession) return@buildJsonObject
    put("active", c.activeIndex)
    put("systemKeyboard", c.systemKeyboardActive)
    if (!judged) put("validation", c.validation?.let { v -> buildJsonObject { put("valid", v.isValid); put("reason", v.reason) } } ?: JsonNull)
}

private fun expected(s: JsonElement, codeRegion: Boolean, judged: Boolean) =
    JsonObject(s.jsonObject.filterKeys { !(it == "regionCaption" && codeRegion) && !(it == "validation" && judged) })

class InputTest {
    @Test
    fun sessionVectors() {
        val cases = loadVectors("core/input.json").filter { it.input.jsonObject.containsKey("package") }
        assertTrue(cases.isNotEmpty())
        for (c in cases) {
            val i = c.input.jsonObject
            val pkg = i["package"]!!.jsonPrimitive.content
            val home = i["spec"]!!.jsonPrimitive.content
            val hasValidator = i["validator"] !is JsonNull
            val source = PlateInputSource.valueOf(i["source"]!!.jsonPrimitive.content)
            val controller = PlateController(specOf(pkg, home).spec, i["values"]!!.strs(), if (hasValidator) unported else null)
            var machine: PlateInputMachine? = null
            var sheet: Int? = null
            var codeRegion = false
            fun mount(id: String) {
                machine?.let(controller::detach)
                val m = PlateInputMachine(
                    controller.spec, { controller.values }, controller::setAt, source,
                    onActiveIndexChanged = { controller.notifyActiveSlotChanged() },
                    onSheetRequested = { sheet = it },
                )
                machine = m
                controller.attach(m)
                controller.validator = if (id == home && hasValidator) unported else null
                codeRegion = specOf(pkg, id).codeRegion
            }
            mount(home)
            // The validator's verdict is only compared where the core decides it.
            fun judged(s: JsonElement) = controller.validator != null && s.jsonObject["rejection"] is JsonNull
            val initial = c.expect.jsonObject["initial"]!!
            assertEquals(expected(initial, codeRegion, judged(initial)), state(controller, codeRegion, judged(initial)), c.name)

            for ((n, step) in c.expect.jsonObject["steps"]!!.jsonArray.withIndex()) {
                val op = step.jsonObject["op"]!!.jsonObject
                fun s(k: String) = op[k]!!.jsonPrimitive.contentOrNull
                // StateFlows conflate; each grain changes at most once per op, except the whole's counter.
                val whole = controller.changes.value
                val completed = controller.completed.value
                val rejection = controller.rejection.value
                val slots = controller.spec.slots.indices.map(controller::slot)
                val before = slots.map { it.value }
                sheet = null
                var result: Boolean? = null
                var threw: String? = null
                try {
                    when (s("op")) {
                        "submit" -> controller.submit(s("char")!!)
                        "backspace" -> controller.backspace()
                        "clear" -> result = controller.clear()
                        "focusSlot" -> controller.focusSlot(op["index"]!!.jsonPrimitive.int)
                        "focusFirstEmpty" -> controller.focusFirstEmpty()
                        "setAt" -> result = controller.setAt(op["index"]!!.jsonPrimitive.int, s("value"))
                        "setGroup" -> result = controller.setGroup(s("key")!!, s("value")!!)
                        "setValues" -> result = controller.setValues(op["values"]!!.strs())
                        "adoptSpec" -> {
                            controller.adoptSpec(specOf(pkg, s("spec")!!).spec, PlateValuePreservation.valueOf(s("preserve")!!))
                            mount(s("spec")!!)
                        }
                        else -> error("unknown op $op")
                    }
                } catch (e: IllegalArgumentException) {
                    threw = "RangeError"
                }
                val fired = buildJsonObject {
                    val w = controller.changes.value - whole
                    if (w > 0) put("whole", w)
                    if (controller.completed.value != completed) put("completed", 1)
                    if (controller.rejection.value !== rejection) put("rejection", 1)
                    slots.forEachIndexed { k, f -> if (f.value != before[k]) put("slot $k", 1) }
                }
                val st = step.jsonObject["state"]!!
                val j = judged(st)
                val actual = buildJsonObject {
                    put("result", result)
                    put("throws", threw)
                    put("sheet", sheet)
                    put("notified", JsonObject(fired.toSortedMap()))
                    put("state", state(controller, codeRegion, j))
                }
                val want = JsonObject(
                    step.jsonObject.filterKeys { it != "op" }.mapValues { (k, v) ->
                        when (k) {
                            "state" -> expected(v, codeRegion, j)
                            "notified" -> JsonObject(v.jsonObject.toSortedMap())
                            else -> v
                        }
                    },
                )
                assertEquals(want, actual, "${c.name} step $n $op")
            }
        }
    }

    @Test
    fun fromTextVectors() {
        val cases = loadVectors("core/values.json").filter { it.input.jsonObject.containsKey("fromText") }
        assertTrue(cases.isNotEmpty())
        for (c in cases) {
            val i = c.input.jsonObject
            val loaded = specOf(i["package"]!!.jsonPrimitive.content, i["spec"]!!.jsonPrimitive.content)
            val p = PlateController.fromText(loaded.spec, i["fromText"]!!.jsonPrimitive.content)
            assertEquals(expected(c.expect, loaded.codeRegion, false), state(p, loaded.codeRegion, false, withSession = false), c.name)
        }
    }

    @Test
    fun outOfRangeSlotStaysNull() {
        val c = PlateController(specOf("albania_plate", "al.private").spec)
        assertSame(c.slot(-1), c.slot(99))
        assertNull(c.slot(99).value)
    }

    @Test
    fun rejectionOutranksValidator() {
        val spec = specOf("albania_plate", "al.private").spec
        val c = PlateController(spec, validator = { PlateValidation.invalid("v") })
        assertEquals("v", c.validation?.reason)
        val r = ValuesRestriction("series", listOf("XX"), "r")
        val restricted = plates.core.values.PlateSpec<Any>(
            "r", spec.country, spec.canvasWidth, spec.canvasHeight, null, spec.slots,
            textGroups = spec.textGroups, restrictions = listOf(r),
        )
        val d = PlateController(restricted, validator = { PlateValidation.invalid("v") })
        assertTrue(!d.setGroup("series", "XX"))
        assertEquals("r", d.validation?.reason)
    }

    @Test
    fun hintsNeverTouchValues() {
        val c = PlateController(specOf("albania_plate", "al.private").spec)
        c.hints.value = listOf("ab", null, null)
        assertEquals("ab", c.hintAt(0))
        assertTrue(c.isEmpty)
    }

    @Test
    fun setTextWritesOnlyWhenDifferent() {
        var writes = 0
        val field = object : PlateTextField {
            override var value = ""
            override fun setSelectionRange(start: Int, end: Int) { writes++ }
        }
        PlateInputMachine.setText(field, "AB") { it }
        PlateInputMachine.setText(field, "AB") { it }
        assertEquals("AB" to 1, field.value to writes)
    }

    @Test
    fun behaviorVectors() {
        for (c in loadVectors("core/input.json").filter { it.input.jsonObject.containsKey("mode") }) {
            val i = c.input.jsonObject
            val got = resolveSlotBehavior(
                PlateMode.valueOf(i["mode"]!!.jsonPrimitive.content),
                plates.core.alphabet.AlphabetInput.valueOf(i["input"]!!.jsonPrimitive.content),
                PlateInputSource.valueOf(i["source"]!!.jsonPrimitive.content),
            )
            assertEquals(c.expect.jsonPrimitive.content, got.name, c.name)
        }
    }
}

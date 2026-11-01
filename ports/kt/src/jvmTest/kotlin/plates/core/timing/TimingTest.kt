package plates.core.timing

import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.boolean
import kotlinx.serialization.json.double
import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import plates.VectorCase
import plates.core.values.Rect
import plates.loadVectors
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class TimingTest {
    private val cases = loadVectors("core/timing.json")

    private fun starting(prefix: String) = cases.filter { it.name.startsWith(prefix) }.also { assertTrue(it.isNotEmpty(), prefix) }

    private fun VectorCase.nums(obj: Any, key: String) = (obj as JsonObject)[key]!!.jsonArray.map { it.jsonPrimitive.double }

    private fun motionJson(m: PlateMotion) = listOf(
        m.effect.name, m.durationMs, PlateCurves.byName.entries.first { it.value === m.curve }.key, m.delayMs,
        m.origin.x, m.origin.y, m.startPoint, m.clockwise, m.softEdge,
    )

    private fun expectedMotion(e: JsonObject) = listOf(
        e["effect"]!!.jsonPrimitive.content, e["durationMs"]!!.jsonPrimitive.content.toLong(), e["curve"]!!.jsonPrimitive.content,
        e["delayMs"]!!.jsonPrimitive.content.toLong(), e["origin"]!!.jsonArray[0].jsonPrimitive.double,
        e["origin"]!!.jsonArray[1].jsonPrimitive.double, e["startPoint"]!!.jsonPrimitive.double,
        e["clockwise"]!!.jsonPrimitive.boolean, e["softEdge"]!!.jsonPrimitive.boolean,
    )

    @Test
    fun curves() {
        for (c in starting("curve ")) {
            val curve = PlateCurves.byName[c.input.jsonObject["curve"]!!.jsonPrimitive.content]!!
            val ts = c.nums(c.input, "t")
            val want = c.nums(c.expect, "value")
            ts.forEachIndexed { i, t -> assertEquals(want[i], curve.transform(t), 1e-6, "${c.name} $t") }
        }
    }

    @Test
    fun motionsAndStyle() {
        assertEquals(expectedMotion(starting("motion default")[0].expect.jsonObject), motionJson(PlateMotion()))
        for (c in starting("style ")) {
            val kind = PlatePartKind.valueOf(c.input.jsonObject["kind"]!!.jsonPrimitive.content)
            assertEquals(expectedMotion(c.expect.jsonObject), motionJson(PlateAnimationStyle().motionFor(PlatePartId(kind, 3))), c.name)
        }
    }

    @Test
    fun delayedProgress() {
        for (c in starting("progress ")) {
            val i = c.input.jsonObject
            val m = PlateAnimationStyle().motionFor(PlatePartId(PlatePartKind.valueOf(i["kind"]!!.jsonPrimitive.content)))
            val delay = i["cueDelayMs"]!!.jsonPrimitive.int.toLong()
            assertEquals(c.expect.jsonObject["totalMs"]!!.jsonPrimitive.int.toLong(), plateCueTotalMs(m, delay))
            val want = c.nums(c.expect, "progress")
            i["atMs"]!!.jsonArray.forEachIndexed { k, ms -> assertEquals(want[k], plateCueProgress(m, delay, ms.jsonPrimitive.double), 1e-9, "${c.name} $ms") }
        }
    }

    @Test
    fun reveal() {
        for (c in starting("reveal ")) {
            val i = c.input.jsonObject
            val b = c.nums(i, "bounds")
            val o = c.nums(i, "origin")
            val frame = PlatePartFrame(PlatePartPhase.valueOf(i["phase"]!!.jsonPrimitive.content), i["progress"]!!.jsonPrimitive.double, PlateMotion())
            val e = c.expect.jsonObject
            assertEquals(e["shown"]!!.jsonPrimitive.double, frame.shown, 1e-12, c.name)
            assertEquals(e["hidden"]!!.jsonPrimitive.boolean, frame.hidden, c.name)
            assertEquals(c.nums(e, "span"), frame.span.toList(), c.name)
            val r = plateRevealRect(Rect.fromLTWH(b[0], b[1], b[2], b[3]), Alignment(o[0], o[1]), frame)
            val want = c.nums(e, "rect")
            assertEquals(listOf(want[0], want[1], want[2], want[3]), listOf(r.left, r.top, r.width, r.height).map { it }, c.name)
        }
    }

    @Test
    fun partsAndStagger() {
        for (c in starting("") .filter { it.name.endsWith(" parts") }) {
            val i = c.input.jsonObject
            val spec = timingSpec(i["package"]!!.jsonPrimitive.content, i["spec"]!!.jsonPrimitive.content)
            val e = c.expect.jsonObject
            val ids = PlatePartId.allOf(spec)
            assertEquals(e["allOf"]!!.names(), ids.map { "$it" }, c.name)
            assertEquals(e["regionCount"]!!.jsonPrimitive.int, plateRegionCount(spec.background), c.name)
            assertEquals(e["dividerCount"]!!.jsonPrimitive.int, plateDividerCount(spec.background), c.name)
            val fwd = PlateStagger.sequence(spec)
            val back = PlateStagger.sequence(spec, 25, reverse = true)
            assertEquals(e["stagger60"]!!.longs(), ids.map { fwd[it]!! }, c.name)
            assertEquals(e["stagger25Reverse"]!!.longs(), ids.map { back[it]!! }, c.name)
            val style = PlateAnimationStyle()
            assertEquals(e["cueLength"]!!.jsonPrimitive.int.toLong(), plateCueLength(style, ids, emptyMap()), c.name)
            assertEquals(e["cueLength60"]!!.jsonPrimitive.int.toLong(), plateCueLength(style, ids, fwd), c.name)
            assertEquals(e["cueLength25Reverse"]!!.jsonPrimitive.int.toLong(), plateCueLength(style, ids, back), c.name)
        }
    }

    @Test
    fun specTransitions() {
        val kinds = PlateSpecTransition(keepKinds = setOf(PlatePartKind.panel, PlatePartKind.slot, PlatePartKind.band))
        val identical = PlateSpecTransition(keepIdentical = true)
        for (c in starting("").filter { " -> " in it.name }) {
            val i = c.input.jsonObject
            val pkg = i["package"]!!.jsonPrimitive.content
            val from = timingSpec(pkg, i["from"]!!.jsonPrimitive.content)
            val to = timingSpec(pkg, i["to"]!!.jsonPrimitive.content)
            val ids = (PlatePartId.allOf(from) + PlatePartId.allOf(to)).distinct()
            val fv = List<String?>(from.slots.size) { null }
            val tv = List<String?>(to.slots.size) { null }
            val e = c.expect.jsonObject
            fun names(f: (PlatePartId) -> Boolean) = ids.filter(f).map { "$it" }.toSet()
            assertEquals(e["samePart"]!!.names().toSet(), names { PlateSpecTransition.samePart(it, from, to, fv, tv) }, c.name)
            assertEquals(e["keepIdentical"]!!.names().toSet(), names { identical.keeps(it, from, to, fv, tv) }, c.name)
            assertEquals(e["keepPanelSlotBand"]!!.names().toSet(), names { kinds.keeps(it, from, to) }, c.name)
        }
    }

    @Test
    fun controllerCues() {
        val c = PlateAnimationController()
        val a = PlatePartId.slot(0)
        assertEquals(PlatePartPhase.settled, c.phaseOf(a))
        c.comeInAll(mapOf(a to 120))
        assertEquals(PlatePartCue(PlatePartPhase.comingIn, 120, 1), c.cueOf(a).value)
        assertEquals(PlatePartPhase.comingIn, c.cueOf(PlatePartId.border).value.phase)
        c.hide(a)
        assertTrue(c.cueOf(a).value.instant)
        c.settleAll()
        assertEquals(PlatePartPhase.settled, c.phaseOf(a))
    }

    @Test
    fun lookTable() {
        val slide = PlateMotion(PlatePartEffect.fadeSlide, origin = Alignment.bottomCenter)
        assertEquals(PlatePartLook(0.5, slideY = 0.3), platePartLook(PlatePartFrame(PlatePartPhase.comingIn, 0.5, slide)))
        val wipe = PlateMotion(PlatePartEffect.wipe)
        assertEquals(PlatePartLook(0.0, clip = true), platePartLook(PlatePartFrame(PlatePartPhase.comingIn, 0.0, wipe)))
        assertEquals(PlatePartLook(1.0), platePartLook(PlatePartFrame.settled))
    }

    private fun kotlinx.serialization.json.JsonElement.names() = jsonArray.map { it.jsonPrimitive.content }

    private fun kotlinx.serialization.json.JsonElement.longs() = (this as JsonArray).map { it.jsonPrimitive.int.toLong() }
}

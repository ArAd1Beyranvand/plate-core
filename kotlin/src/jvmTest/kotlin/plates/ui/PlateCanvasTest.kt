package plates.ui

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import plates.core.input.PlateController
import plates.core.input.PlateInputSource
import plates.core.input.PlateMode
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import plates.core.timing.PlateAnimationController
import plates.core.timing.PlatePartId
import plates.core.timing.plateCueTotalMs
import plates.render.Draw
import plates.render.renderSpecOf

class PlateCanvasTest {
    private val spec = renderSpecOf("germany_plate", "de.car").spec

    private fun texts(c: PlateCanvas) = c.displayList().mapNotNull { (it.draw as? Draw.Text)?.text }

    @Test
    fun constructsTakesValuesReadsBackPaints() {
        val c = PlateCanvas(spec)
        assertTrue(c.values.all { it == null })
        assertEquals(listOf("D"), texts(c))

        c.setValues(listOf("B", "X", "Y", "1", "2", null, null))
        assertEquals(listOf("B", "X", "Y", "1", "2"), c.values.take(5))
        assertEquals(listOf("D", "B", "X", "Y", "1", "2"), texts(c))

        val svg = c.svg()
        assertTrue("viewBox=\"0 0 520 110\"" in svg, svg.take(200))
        assertTrue(">B</text>" in svg)
    }

    @Test
    fun leavesTypedSlotsToNativeInputs() {
        val c = PlateCanvas(spec, values = listOf("B"), mode = PlateMode.input, inputSource = PlateInputSource.system)
        assertEquals(spec.slots.indices.toList(), c.slotInputs().map { it.index })
        assertEquals(listOf("D", "?", "B", "?", "?", "?", "?", "?", "?"), texts(c)) // the fields still paint glyphs and placeholders
    }

    @Test
    fun sharesAHostController() {
        val controller = PlateController(spec)
        val c = PlateCanvas(spec, controller)
        controller.setValues(listOf("M"))
        assertEquals("M", c.values[0])
        assertEquals(listOf("D", "M"), texts(c))
    }
}

class PlateUiTest {
    private val spec = renderSpecOf("germany_plate", "de.car").spec

    @Test
    fun clockDrivesFramesThroughTheTimingModel() {
        var t = 0.0
        val animation = PlateAnimationController()
        val c = PlateCanvas(spec, animation = animation, now = { t })
        val settled = c.displayList()
        animation.comeInAll()
        val start = c.displayList()
        assertTrue(c.animating)
        assertTrue(start != settled)
        val total = plateCueTotalMs(animation.style.motionFor(PlatePartId.background), 0)
        t = 10_000.0 + total
        assertEquals(false, c.animating)
        assertTrue(c.displayList() != start)
    }

    @Test
    fun viewFormatsAndPaints() {
        assertEquals("BX12", plateText(listOf("B", null, "X", "", "12")))
        assertEquals("none", plateViewSvg(spec, listOf(null), emptySvg = "none"))
        assertTrue(">B</text>" in plateViewSvg(spec, listOf("B")))
    }

    @Test
    fun selectorEmitsOnlyChanges() = runBlocking {
        val controller = PlateController(spec)
        val seen = mutableListOf<String?>()
        val job = launch(Dispatchers.Unconfined) { controller.select { it.values[0] }.collect { seen += it } }
        controller.setAt(0, "B")
        controller.setAt(1, "X")
        controller.setAt(0, "M")
        job.cancel()
        assertEquals(listOf(null, "B", "M"), seen)
    }
}

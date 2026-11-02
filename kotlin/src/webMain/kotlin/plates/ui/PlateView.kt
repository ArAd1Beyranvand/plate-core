package plates.ui

import kotlinx.browser.document
import kotlinx.browser.window
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.flow.drop
import kotlinx.coroutines.flow.merge
import kotlinx.coroutines.launch
import org.w3c.dom.HTMLElement
import org.w3c.dom.HTMLInputElement

/** The page clock for [PlateCanvas]'s `now`, so animations run in real time. */
fun pageNow(): Double = window.performance.now()

/**
 * [D2][D7] Mounts [canvas] in [host]: the SVG from the display list, and one native `<input>`
 * per [PlateCanvas.slotInputs] box over it. Inputs survive repaints so focus and caret stay;
 * while [PlateCanvas.animating], repaints once per animation frame [H11].
 */
fun mountPlate(host: HTMLElement, canvas: PlateCanvas, scope: CoroutineScope = MainScope()): Job {
    host.style.position = "relative"
    val face = document.createElement("div") as HTMLElement
    host.appendChild(face)
    var inputs = emptyList<HTMLInputElement>()
    var slots = emptyList<SlotInput>()
    var ticking = false
    fun paint() {
        face.innerHTML = canvas.svg()
        val next = canvas.slotInputs()
        if (next != slots) {
            inputs.forEach { it.remove() }
            slots = next
            inputs = next.map { s ->
                slotInputElement(s, "", canvas.spec.canvasWidth, canvas.spec.canvasHeight).also { input ->
                    input.oninput = { canvas.controller.setAt(s.index, input.value.ifEmpty { null }) }
                    host.appendChild(input)
                }
            }
        }
        slots.zip(inputs).forEach { (s, input) ->
            val v = canvas.values.getOrNull(s.index) ?: ""
            if (input.value != v) input.value = v
        }
        if (canvas.animating && !ticking) {
            ticking = true
            window.requestAnimationFrame { ticking = false; paint() }
        }
    }
    paint()
    return scope.launch { merge(canvas.controller.changes.drop(1), canvas.controller.rejection.drop(1)).collect { paint() } }
}

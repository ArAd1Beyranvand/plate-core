package plates.embed

import kotlinx.browser.document
import kotlinx.browser.window
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.w3c.dom.HTMLElement
import plates.core.input.PlateController
import plates.core.timing.PlateAnimationController
import plates.core.timing.PlatePartId
import plates.core.timing.PlateSpecTransition
import plates.core.timing.PlateStagger
import plates.render.plateTheme
import plates.render.planSpecTransition
import plates.ui.PlateCanvas
import plates.ui.pageNow

/** What the app plays when a plate's spec changes. */
val specTransition = PlateSpecTransition(keepIdentical = true, morphBackground = true)

/** The outgoing plate: what it showed, kept after its canvas is gone. */
class Outgoing(val canvas: PlateCanvas, val values: List<String?>, val hints: List<String?>?)

fun outgoing(c: PlateCanvas) = Outgoing(c, c.values, c.controller.hints.value)

/** A plate coming in with nothing before it: every part staggers in. */
fun introduce(next: PlateCanvas, anim: PlateAnimationController) = anim.comeInAll(PlateStagger.sequence(next.spec, specTransition.stepMs))

/** A plate about to be dropped by the gallery: every part staggers out. */
fun leave(c: PlateCanvas, anim: PlateAnimationController) = anim.goOutAll(PlateStagger.sequence(c.spec, specTransition.stepMs, reverse = true))

/**
 * [D1][D9] A spec change as the canvas plays it: [from] takes itself apart in a ghost over [stage]
 * while [next] waits to come in after it, the face fading between their colours and the box
 * growing to the next plate's height. Returns what ends it early.
 */
fun swapSpec(scope: CoroutineScope, stage: HTMLElement, art: HTMLElement, from: Outgoing, next: PlateCanvas, anim: PlateAnimationController): () -> Unit {
    val old = from.canvas
    val plan = planSpecTransition(specTransition, anim.style, old.spec, next.spec, from.values, next.values)
    val ms = plan.outLengthMs
    anim.comeInAll(plan.inDelays)
    plan.hidden.forEach(anim::hide)
    plan.morphed.forEach(anim::settle)
    next.morphFrom(plateTheme(old.spec, old.theme, from.values), ms.toDouble())

    val ghostAnim = PlateAnimationController(anim.style)
    ghostAnim.goOutAll(plan.outDelays)
    plan.kept.forEach(ghostAnim::settle)
    // The corner and width draw nothing; they only shape the clip the leaving parts are held in.
    plan.morphed.forEach { if (it == PlatePartId.corner || it == PlatePartId.borderWidth) ghostAnim.settle(it) else ghostAnim.hide(it) }
    val controller = PlateController(old.spec, from.values)
    controller.hints.value = from.hints
    val ghost = PlateCanvas(
        old.spec, controller, theme = old.theme, country = old.country, mode = old.mode, inputSource = old.inputSource,
        animation = ghostAnim, now = ::pageNow,
    )
    val el = document.createElement("div") as HTMLElement
    el.setAttribute("aria-hidden", "true")
    el.style.cssText = "position:absolute;left:0;top:0;width:100%;pointer-events:none"
    var ended = false
    fun paintGhost() {
        el.innerHTML = ghost.svg()
        el.firstElementChild?.setAttribute("style", "width:100%;height:auto;display:block")
        if (!ended && ghost.animating) window.requestAnimationFrame { paintGhost() }
    }
    stage.appendChild(el)
    paintGhost()

    if (ms > 0) {
        stage.style.height = "${stage.offsetHeight}px"
        stage.offsetHeight // flush, so the next height transitions from this one
        window.requestAnimationFrame {
            stage.style.transition = "height ${ms}ms ease-in-out"
            stage.style.height = "${art.offsetHeight}px"
        }
    }
    fun end() {
        if (ended) return
        ended = true
        el.remove()
        stage.style.transition = ""
        stage.style.height = ""
    }
    val timer = scope.launch {
        delay(ms)
        end()
        plan.kept.forEach(anim::settle)
    }
    return { timer.cancel(); end(); anim.settleAll() }
}

package plates.ui

import plates.core.timing.PlateAnimationController
import plates.core.timing.PlatePartCue
import plates.core.timing.PlatePartFrame
import plates.core.timing.PlatePartId
import plates.core.timing.PlatePartPhase
import plates.core.timing.plateCueProgress
import plates.render.Frames

/**
 * [H11] The animation driver: remembers when each part's cue arrived and turns
 * (cue, elapsed) into frames through the core timing model. The UI ticks it per animation frame.
 */
class PartClock(private val animation: PlateAnimationController, private val now: () -> Double) {
    private val started = HashMap<PlatePartId, Pair<PlatePartCue, Double>>()

    private fun progress(id: PlatePartId, cue: PlatePartCue, at: Double, t: Double) =
        if (cue.instant || cue.phase == PlatePartPhase.settled) 1.0
        else plateCueProgress(animation.style.motionFor(id), cue.delayMs, t - at)

    fun frames(): Frames {
        val t = now()
        return { id ->
            val cue = animation.cueOf(id).value
            val s = started[id]?.takeIf { it.first == cue } ?: (cue to t).also { started[id] = it }
            PlatePartFrame(cue.phase, progress(id, cue, s.second, t), animation.style.motionFor(id))
        }
    }

    /** True while some part seen so far is still moving. */
    val running: Boolean
        get() = now().let { t -> started.any { (id, s) -> progress(id, s.first, s.second, t) < 1 } }
}

package plates.render

import plates.core.timing.PlateAnimationStyle
import plates.core.timing.PlatePartId
import plates.core.timing.PlateSpecTransition
import plates.core.timing.PlateStagger
import plates.core.timing.plateCueLength
import plates.core.values.PlateSpec

/** [D1][D9] What a spec change plays: the ghost takes the old plate apart, the new one comes in after it. */
class SpecTransitionPlan(
    /** The outgoing parts' goingOut delays; kept and morphed parts are absent. */
    val outDelays: Map<PlatePartId, Long>,
    /** The incoming parts' comingIn delays, each after the out stagger. */
    val inDelays: Map<PlatePartId, Long>,
    /** Parts of the old plate the ghost shows settled until it goes. */
    val kept: Set<PlatePartId>,
    /** Parts of the new plate hidden while the ghost shows their old twin. */
    val hidden: Set<PlatePartId>,
    /** The face and border: the new plate's settle at once, its colour tweening, and the ghost leaves them out. */
    val morphed: Set<PlatePartId>,
    /** How long the ghost runs, and so how long the canvas takes to resize. */
    val outLengthMs: Long,
)

private val faceParts = setOf(PlatePartId.background, PlatePartId.corner, PlatePartId.borderWidth, PlatePartId.borderColor, PlatePartId.border)

fun planSpecTransition(
    t: PlateSpecTransition,
    style: PlateAnimationStyle,
    from: PlateSpec<*>,
    to: PlateSpec<*>,
    fromValues: List<String?>,
    toValues: List<String?>,
): SpecTransitionPlan {
    fun keeps(id: PlatePartId) = t.keeps(id, from, to, fromValues, toValues)
    val morphed = if (t.morphBackground) faceParts else emptySet()
    val outDelays = PlateStagger.sequence(from, t.stepMs, reverse = true).filterKeys { !keeps(it) && it !in morphed }
    val outLengthMs = plateCueLength(style, outDelays.keys, outDelays)
    val inDelays = PlateStagger.sequence(to, t.stepMs).mapValues { it.value + outLengthMs }
    return SpecTransitionPlan(
        outDelays, inDelays,
        PlatePartId.allOf(from).filter(::keeps).toSet(),
        PlatePartId.allOf(to).filter(::keeps).toSet(),
        morphed, outLengthMs,
    )
}

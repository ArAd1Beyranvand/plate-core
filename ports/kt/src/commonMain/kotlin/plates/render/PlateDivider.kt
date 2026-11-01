package plates.render

import plates.core.timing.PlatePartEffect
import plates.core.timing.PlatePartFrame
import plates.core.timing.PlatePartPhase
import plates.core.values.Color
import plates.core.values.Rect

/** Which end of a divider its effect starts at: start is the left or top end. */
enum class DividerOrigin { start, end }

private const val RAMP_STEPS = 3

/**
 * [D1] The rects a divider paints in [r] this frame, with the alpha fraction of each:
 * the shown span along its long axis, softened at the moving edge when the motion asks.
 */
fun dividerSpans(r: Rect, frame: PlatePartFrame, origin: DividerOrigin? = null): List<Pair<Rect, Double>> {
    if (frame.hidden) return emptyList()
    val motion = frame.motion
    if (frame.phase == PlatePartPhase.settled || (motion.effect != PlatePartEffect.wipe && motion.effect != PlatePartEffect.draw)) {
        return listOf(r to frame.shown)
    }
    val vertical = r.height > r.width
    val fromEnd = (origin ?: if ((if (vertical) motion.origin.y else motion.origin.x) > 0) DividerOrigin.end else DividerOrigin.start) == DividerOrigin.end
    var (a, b) = frame.span
    if (fromEnd) a = (1 - b).also { b = 1 - a }
    val whole = a <= 0 && b >= 1
    val lo = if (vertical) r.top else r.left
    val len = if (vertical) r.height else r.width
    fun along(f0: Double, f1: Double) =
        if (vertical) Rect(r.left, lo + len * f0, r.right, lo + len * f1) else Rect(lo + len * f0, r.top, lo + len * f1, r.bottom)
    // The moving edge: the head on the way in, the tail on the way out.
    val moving = if ((frame.phase == PlatePartPhase.comingIn) != fromEnd) b else a
    val ramp = if (motion.softEdge && !whole) minOf(maxOf((if (vertical) r.width else r.height) * 3 / len, 0.0), b - a) else 0.0
    if (ramp <= 0) return listOf(along(a, b) to 1.0)
    val towardLo = moving == a
    val out = mutableListOf((if (towardLo) along(a + ramp, b) else along(a, b - ramp)) to 1.0)
    val step = ramp / RAMP_STEPS
    for (i in 0 until RAMP_STEPS) {
        val f = i * step
        val span = if (towardLo) along(a + ramp - f - step, a + ramp - f) else along(b - ramp + f, b - ramp + f + step)
        out.add(span to (RAMP_STEPS - i).toDouble() / (RAMP_STEPS + 1))
    }
    return out
}

/** PlateDividerPainter: one divider line in [r], clipped to [clip] when given. */
fun paintDivider(c: DisplayList, r: Rect?, color: Color, frame: PlatePartFrame, clip: RRect? = null, origin: DividerOrigin? = null) {
    if (frame.hidden || r == null) return
    if (clip != null) {
        c.save()
        c.clipRRect(clip)
    }
    for ((rect, alpha) in dividerSpans(r, frame, origin)) c.rect(rect, Paint(withAlpha(color, alpha)))
    if (clip != null) c.restore()
}

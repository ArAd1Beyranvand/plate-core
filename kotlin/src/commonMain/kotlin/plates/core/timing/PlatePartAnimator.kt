package plates.core.timing

import plates.core.values.Rect

/**
 * Where one part is right now: what its painter reads. [progress] runs 0→1 across the current transition,
 * delay and curve already applied (see [plateCueProgress]); it is 1 while [phase] is settled.
 */
data class PlatePartFrame(val phase: PlatePartPhase, val progress: Double, val motion: PlateMotion) {
    /** How much of the part shows, 0 (gone) to 1 (as settled). */
    val shown: Double
        get() = when (phase) {
            PlatePartPhase.settled -> 1.0
            PlatePartPhase.comingIn -> progress
            PlatePartPhase.goingOut -> 1 - progress
        }

    /** True once a part has nothing left to paint. */
    val hidden get() = shown <= 0

    /** The span of a directional effect, as fractions along the run from its origin end. */
    val span: Pair<Double, Double>
        get() = when (phase) {
            PlatePartPhase.settled -> 0.0 to 1.0
            PlatePartPhase.comingIn -> 0.0 to progress
            PlatePartPhase.goingOut -> progress to 1.0
        }

    companion object {
        val settled = PlatePartFrame(PlatePartPhase.settled, 1.0, PlateMotion())
    }
}

/** The whole run of a cue in ms: the motion's delay, the cue's delay, then the duration. */
fun plateCueTotalMs(motion: PlateMotion, cueDelayMs: Long) = motion.delayMs + cueDelayMs + motion.durationMs

/**
 * Progress [atMs] into a cue. The delays are the head of the curve's interval: 0 until they pass, then the
 * curve over the rest. A zero-length run is complete at once.
 */
fun plateCueProgress(motion: PlateMotion, cueDelayMs: Long, atMs: Double): Double {
    val total = plateCueTotalMs(motion, cueDelayMs)
    if (total <= 0) return 1.0
    val begin = (motion.delayMs + cueDelayMs).toDouble() / total
    val t = if (begin >= 1) (if (atMs / total >= 1) 1.0 else 0.0) else ((atMs / total - begin) / (1 - begin)).coerceIn(0.0, 1.0)
    return if (t == 0.0 || t == 1.0) t else motion.curve.transform(t)
}

/** The part of [bounds] a wipe from [origin] leaves visible. An axis on which [origin] is centred grows from the middle. */
fun plateRevealRect(bounds: Rect, origin: Alignment, frame: PlatePartFrame): Rect {
    val (a, b) = frame.span
    if (a <= 0 && b >= 1) return bounds
    val centred = origin.x == 0.0 && origin.y == 0.0

    fun axis(o: Double, lo: Double, hi: Double, start: Boolean): Double {
        val len = hi - lo
        if (o == 0.0) {
            if (!centred) return if (start) lo else hi
            val f = if (start) (1 - (b - a)) / 2 else (1 + (b - a)) / 2
            return lo + len * f
        }
        val f0 = if (o < 0) a else 1 - b
        val f1 = if (o < 0) b else 1 - a
        return lo + len * (if (start) f0 else f1)
    }

    return Rect.fromLTRB(
        axis(origin.x, bounds.left, bounds.right, true),
        axis(origin.y, bounds.top, bounds.bottom, true),
        axis(origin.x, bounds.left, bounds.right, false),
        axis(origin.y, bounds.top, bounds.bottom, false),
    )
}

/**
 * What one frame asks of a part's graphics layer: alpha, scale about [scaleOrigin], a translation of
 * ([slideX], [slideY]) times the part's size, and whether to clip to [plateRevealRect].
 */
data class PlatePartLook(
    val alpha: Double,
    val scale: Double = 1.0,
    val scaleOrigin: Alignment = Alignment.center,
    val slideX: Double = 0.0,
    val slideY: Double = 0.0,
    val clip: Boolean = false,
)

/** fade = alpha, wipe/draw = clip + alpha gate, fadeScale = scale 0.4→1, fadeSlide = slide in from 0.6 of the size. */
fun platePartLook(frame: PlatePartFrame): PlatePartLook {
    if (frame.phase == PlatePartPhase.settled) return PlatePartLook(1.0)
    val shown = frame.shown
    val origin = frame.motion.origin
    return when (frame.motion.effect) {
        PlatePartEffect.fade -> PlatePartLook(shown)
        PlatePartEffect.wipe, PlatePartEffect.draw -> PlatePartLook(if (shown <= 0) 0.0 else 1.0, clip = true)
        PlatePartEffect.fadeScale -> PlatePartLook(shown, scale = 0.4 + 0.6 * shown, scaleOrigin = origin)
        PlatePartEffect.fadeSlide -> PlatePartLook(shown, slideX = origin.x * 0.6 * (1 - shown), slideY = origin.y * 0.6 * (1 - shown))
    }
}

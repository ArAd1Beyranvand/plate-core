package plates.core.timing

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import plates.core.values.PlateFill
import plates.core.values.paintsPanel
import plates.core.values.PlateSection
import plates.core.values.PlateSpec
import plates.core.values.Rect
import kotlin.math.PI
import kotlin.math.pow
import kotlin.math.sin

/** Where a plate part is in its lifecycle. [settled] paints the part exactly as a plate without animation does. */
enum class PlatePartPhase { comingIn, settled, goingOut }

/** The kinds of visual part a plate is made of. Closed: the library owns the renderer, so it owns the list. */
enum class PlatePartKind {
    background, corner, region, divider, borderWidth, borderColor, border, panel, flag, caption,
    band, bandCorner, rule, label, decal, slot, mirror,
}

/** A stable address for one part of a plate: its [kind] and, for a kind a spec has several of, its [index]. */
data class PlatePartId(val kind: PlatePartKind, val index: Int = 0) {
    override fun toString() = if (index == 0 && kind in single) kind.name else "${kind.name} $index"

    companion object {
        private val single = setOf(
            PlatePartKind.background, PlatePartKind.corner, PlatePartKind.borderWidth, PlatePartKind.borderColor,
            PlatePartKind.border, PlatePartKind.panel, PlatePartKind.flag, PlatePartKind.caption,
        )

        val background = PlatePartId(PlatePartKind.background)
        val corner = PlatePartId(PlatePartKind.corner)
        val borderColor = PlatePartId(PlatePartKind.borderColor)
        val borderWidth = PlatePartId(PlatePartKind.borderWidth)
        val border = PlatePartId(PlatePartKind.border)
        val panel = PlatePartId(PlatePartKind.panel)
        val flag = PlatePartId(PlatePartKind.flag)
        val caption = PlatePartId(PlatePartKind.caption)

        fun region(index: Int) = PlatePartId(PlatePartKind.region, index)
        fun divider(index: Int) = PlatePartId(PlatePartKind.divider, index)
        fun band(index: Int) = PlatePartId(PlatePartKind.band, index)
        fun bandCorner(index: Int) = PlatePartId(PlatePartKind.bandCorner, index)
        fun rule(index: Int) = PlatePartId(PlatePartKind.rule, index)
        fun label(index: Int) = PlatePartId(PlatePartKind.label, index)
        fun decal(index: Int) = PlatePartId(PlatePartKind.decal, index)
        fun slot(index: Int) = PlatePartId(PlatePartKind.slot, index)
        fun mirror(index: Int) = PlatePartId(PlatePartKind.mirror, index)

        /** Every part [spec] renders, in painting order. */
        fun allOf(spec: PlateSpec<*>): List<PlatePartId> = buildList {
            add(background)
            add(corner)
            for (i in 0 until plateRegionCount(spec.background)) add(region(i))
            for (i in 0 until plateDividerCount(spec.background)) add(divider(i))
            add(borderWidth)
            add(borderColor)
            add(border)
            if (spec.panel != null) addAll(listOf(panel, flag, caption))
            for (i in spec.bands.indices) add(band(i))
            for (i in spec.bands.indices) add(bandCorner(i))
            for (i in spec.rules.indices) add(rule(i))
            for (i in spec.labels.indices) add(label(i))
            for (i in spec.decals.indices) add(decal(i))
            for (i in spec.mirrors.indices) add(mirror(i))
            for (i in spec.slots.indices) add(slot(i))
        }
    }
}

/** How many leaves [section] has — the [PlatePartKind.region] count. */
fun plateRegionCount(section: PlateSection) = section.layout(Rect.fromLTWH(0.0, 0.0, 0.0, 0.0)).leaves.size

/** How many dividers [section] draws — the [PlatePartKind.divider] count. */
fun plateDividerCount(section: PlateSection) = section.layout(Rect.fromLTWH(0.0, 0.0, 0.0, 0.0)).dividers.size

/** How a part appears and disappears. */
enum class PlatePartEffect {
    fade,

    /** A clip that grows from [PlateMotion.origin] on the way in and erases from the same side on the way out. */
    wipe,

    /** Grows from [PlateMotion.origin], fading as it goes. */
    fadeScale,

    /** Slides in from [PlateMotion.origin], fading as it goes. */
    fadeSlide,

    /** The stroke travels the perimeter (border) or the line's length (divider, rule); any other part treats it as [wipe]. */
    draw,
}

/** Where a directional effect starts, in [-1, 1] on both axes; the centre is (0, 0). */
data class Alignment(val x: Double, val y: Double) {
    companion object {
        val center = Alignment(0.0, 0.0)
        val centerLeft = Alignment(-1.0, 0.0)
        val topCenter = Alignment(0.0, -1.0)
        val bottomCenter = Alignment(0.0, 1.0)
    }
}

/** A progress curve on [0, 1] with Flutter's exact shape. */
fun interface PlateCurve {
    fun transform(t: Double): Double
}

/** Flutter's `Cubic`: the bezier from (0,0) to (1,1) with control points (a,b) and (c,d), solved by bisection. */
class PlateCubic(val a: Double, val b: Double, val c: Double, val d: Double) : PlateCurve {
    override fun transform(t: Double): Double {
        if (t == 0.0 || t == 1.0) return t
        var start = 0.0
        var end = 1.0
        while (true) {
            val mid = (start + end) / 2
            val estimate = evaluate(a, c, mid)
            if (kotlin.math.abs(t - estimate) < 0.001) return evaluate(b, d, mid)
            if (estimate < t) start = mid else end = mid
        }
    }

    private fun evaluate(p: Double, q: Double, m: Double) = 3 * p * (1 - m) * (1 - m) * m + 3 * q * (1 - m) * m * m + m * m * m
}

/** The curves by their Flutter names. */
object PlateCurves {
    val linear = PlateCurve { it }
    val ease = PlateCubic(0.25, 0.1, 0.25, 1.0)
    val easeInOut = PlateCubic(0.42, 0.0, 0.58, 1.0)
    val easeInOutCubic = PlateCubic(0.645, 0.045, 0.355, 1.0)
    val easeOut = PlateCubic(0.0, 0.0, 0.58, 1.0)
    val easeInCubic = PlateCubic(0.55, 0.055, 0.675, 0.19)
    val easeOutBack = PlateCubic(0.175, 0.885, 0.32, 1.275)
    val easeOutCubic = PlateCubic(0.215, 0.61, 0.355, 1.0)
    val elasticOut = PlateCurve {
        if (it == 0.0 || it == 1.0) it else 2.0.pow(-10 * it) * sin((it - 0.1) * (PI * 2) / 0.4) + 1
    }

    val byName: Map<String, PlateCurve> = mapOf(
        "linear" to linear, "ease" to ease, "easeInOut" to easeInOut, "easeInOutCubic" to easeInOutCubic,
        "easeOut" to easeOut, "easeInCubic" to easeInCubic, "easeOutBack" to easeOutBack, "easeOutCubic" to easeOutCubic, "elasticOut" to elasticOut,
    )
}

/** The timing and look of one part's transitions; times are whole milliseconds. */
data class PlateMotion(
    val effect: PlatePartEffect = PlatePartEffect.fade,
    val durationMs: Long = 420,
    val curve: PlateCurve = PlateCurves.easeInOutCubic,
    /** Added before every transition of the part; a cue's own delay adds to it. */
    val delayMs: Long = 0,
    /** Where a directional effect starts. For a divider or rule only the sign along its axis counts. */
    val origin: Alignment = Alignment.centerLeft,
    /** For the border: where the stroke starts, as a fraction of the perimeter clockwise from the top-left corner. */
    val startPoint: Double = 0.0,
    val clockwise: Boolean = true,
    /** For a divider or rule: a short alpha ramp at the moving edge. */
    val softEdge: Boolean = false,
)

/** The [PlateMotion] each part uses: one per kind, with optional overrides for single parts. */
class PlateAnimationStyle(
    val byKind: Map<PlatePartKind, PlateMotion> = defaults,
    val overrides: Map<PlatePartId, PlateMotion> = emptyMap(),
) {
    fun motionFor(id: PlatePartId): PlateMotion = overrides[id] ?: byKind[id.kind] ?: PlateMotion()

    companion object {
        val defaults: Map<PlatePartKind, PlateMotion> = mapOf(
            PlatePartKind.background to PlateMotion(PlatePartEffect.wipe, origin = Alignment.center),
            PlatePartKind.region to PlateMotion(PlatePartEffect.wipe),
            PlatePartKind.divider to PlateMotion(PlatePartEffect.draw, origin = Alignment.topCenter, softEdge = true),
            PlatePartKind.corner to PlateMotion(PlatePartEffect.fade, durationMs = 600),
            PlatePartKind.borderWidth to PlateMotion(PlatePartEffect.fade, durationMs = 600),
            PlatePartKind.borderColor to PlateMotion(PlatePartEffect.fade, durationMs = 600),
            PlatePartKind.border to PlateMotion(PlatePartEffect.draw, durationMs = 900),
            PlatePartKind.panel to PlateMotion(PlatePartEffect.wipe),
            PlatePartKind.flag to PlateMotion(PlatePartEffect.wipe),
            PlatePartKind.caption to PlateMotion(PlatePartEffect.wipe, origin = Alignment.topCenter),
            PlatePartKind.band to PlateMotion(PlatePartEffect.wipe),
            PlatePartKind.bandCorner to PlateMotion(PlatePartEffect.fade),
            PlatePartKind.rule to PlateMotion(PlatePartEffect.draw, origin = Alignment.topCenter, softEdge = true),
            PlatePartKind.label to PlateMotion(PlatePartEffect.wipe),
            PlatePartKind.decal to PlateMotion(PlatePartEffect.fadeScale, origin = Alignment.center),
            PlatePartKind.slot to PlateMotion(PlatePartEffect.fadeSlide, origin = Alignment.bottomCenter),
            PlatePartKind.mirror to PlateMotion(PlatePartEffect.fadeSlide, origin = Alignment.bottomCenter),
        )
    }
}

/**
 * One instruction to a part: go to [phase] after [delayMs]. [serial] tells a repeated instruction from a
 * stale one, so cueing `comingIn` twice replays.
 */
data class PlatePartCue(
    val phase: PlatePartPhase,
    val delayMs: Long = 0,
    val serial: Int = 0,
    /** Jump to the end of [phase] with no transition. */
    val instant: Boolean = false,
) {
    companion object {
        val settled = PlatePartCue(PlatePartPhase.settled)
    }
}

/**
 * Drives the phases of a plate's parts, all at once or one at a time. Each part collects only its own cue,
 * so cueing one part recomposes nothing else. Every part starts [PlatePartPhase.settled].
 */
class PlateAnimationController(style: PlateAnimationStyle = PlateAnimationStyle()) {
    private val styleFlow = MutableStateFlow(style)
    private val cues = HashMap<PlatePartId, MutableStateFlow<PlatePartCue>>()
    private var fallback = PlatePartCue.settled
    private var serial = 0

    val styleState: StateFlow<PlateAnimationStyle> get() = styleFlow

    var style: PlateAnimationStyle
        get() = styleFlow.value
        set(value) {
            styleFlow.value = value
        }

    /** The live cue for [id]; a part collects this. */
    fun cueOf(id: PlatePartId): StateFlow<PlatePartCue> = notifierOf(id)

    /** The phase [id] was last told to take. */
    fun phaseOf(id: PlatePartId) = (cues[id]?.value ?: fallback).phase

    private fun notifierOf(id: PlatePartId) = cues.getOrPut(id) { MutableStateFlow(fallback) }

    fun cue(id: PlatePartId, phase: PlatePartPhase, delayMs: Long = 0) {
        notifierOf(id).value = PlatePartCue(phase, delayMs, ++serial)
    }

    fun comeIn(id: PlatePartId, delayMs: Long = 0) = cue(id, PlatePartPhase.comingIn, delayMs)

    fun goOut(id: PlatePartId, delayMs: Long = 0) = cue(id, PlatePartPhase.goingOut, delayMs)

    fun settle(id: PlatePartId) = cue(id, PlatePartPhase.settled)

    /** Takes [id] straight to gone, with no transition. */
    fun hide(id: PlatePartId) {
        notifierOf(id).value = PlatePartCue(PlatePartPhase.goingOut, serial = ++serial, instant = true)
    }

    /** Cues every part, including ones not mounted yet, to [phase]. A part named in [delays] waits that long first. */
    fun cueAll(phase: PlatePartPhase, delays: Map<PlatePartId, Long> = emptyMap()) {
        val s = ++serial
        fallback = PlatePartCue(phase, serial = s)
        for (id in cues.keys + delays.keys) notifierOf(id).value = PlatePartCue(phase, delays[id] ?: 0, s)
    }

    fun comeInAll(delays: Map<PlatePartId, Long> = emptyMap()) = cueAll(PlatePartPhase.comingIn, delays)

    fun goOutAll(delays: Map<PlatePartId, Long> = emptyMap()) = cueAll(PlatePartPhase.goingOut, delays)

    fun settleAll() = cueAll(PlatePartPhase.settled)
}

/** Delay maps for [PlateAnimationController.cueAll]: a plate composing itself part by part. */
object PlateStagger {
    /** Each of [spec]'s parts [stepMs] after the one before, in painting order; [reverse] for a plate taking itself apart. */
    fun sequence(spec: PlateSpec<*>, stepMs: Long = 60, reverse: Boolean = false): Map<PlatePartId, Long> {
        val ids = PlatePartId.allOf(spec)
        val ordered = if (reverse) ids.reversed() else ids
        return ordered.withIndex().associateTo(LinkedHashMap()) { (i, id) -> id to stepMs * i }
    }
}

/** How long a [PlateAnimationController.cueAll] with [delays] runs under [style], for the parts in [ids]. */
fun plateCueLength(style: PlateAnimationStyle, ids: Iterable<PlatePartId>, delays: Map<PlatePartId, Long>): Long {
    var longest = 0L
    for (id in ids) {
        val m = style.motionFor(id)
        longest = maxOf(longest, (delays[id] ?: 0) + m.delayMs + m.durationMs)
    }
    return longest
}

/**
 * What a canvas does when its spec changes: the old plate goes out part by part, then the new one comes in,
 * except the parts [keeps] — those swap in place with no transition.
 *
 * A part is kept when its kind is in [keepKinds] and both plates have it, or when [keep] says so.
 */
class PlateSpecTransition(
    val keepKinds: Set<PlatePartKind> = emptySet(),
    /** Per-part decision from the outgoing and incoming plates; overrides [keepKinds] when it returns non-null. */
    val keep: ((PlatePartId, PlateSpec<*>, PlateSpec<*>) -> Boolean?)? = null,
    /** Also keep every part both plates draw the same way — see [samePart]. */
    val keepIdentical: Boolean = false,
    /** The face's base colour stays put and blends into the next plate's while the canvas resizes. */
    val morphBackground: Boolean = false,
    val stepMs: Long = 60,
) {
    /** [fromValues] and [toValues] are the characters each plate shows, for judging slots; without them no slot is identical. */
    fun keeps(
        id: PlatePartId,
        from: PlateSpec<*>,
        to: PlateSpec<*>,
        fromValues: List<String?>? = null,
        toValues: List<String?>? = null,
    ): Boolean {
        if (id.kind == PlatePartKind.bandCorner) return keeps(PlatePartId.band(id.index), from, to, fromValues, toValues)
        keep?.invoke(id, from, to)?.let { return it }
        if (keepIdentical && samePart(id, from, to, fromValues, toValues)) return true
        return id.kind in keepKinds && id in PlatePartId.allOf(from) && id in PlatePartId.allOf(to)
    }

    companion object {
        /**
         * True when [from] and [to] would paint [id] identically, as far as the specs say: same canvas, and the
         * part's own data equal. The border and the face behind the regions always redraw.
         */
        fun samePart(
            id: PlatePartId,
            from: PlateSpec<*>,
            to: PlateSpec<*>,
            fromValues: List<String?>? = null,
            toValues: List<String?>? = null,
        ): Boolean {
            if (from.canvasWidth != to.canvasWidth || from.canvasHeight != to.canvasHeight) return false
            val i = id.index
            when (id.kind) {
                PlatePartKind.panel, PlatePartKind.flag, PlatePartKind.caption -> {
                    val a = from.panel ?: return false
                    val b = to.panel ?: return false
                    return from.country == to.country &&
                        from.country.panelColor == to.country.panelColor &&
                        a.box == b.box && a.flagScale == b.flagScale && a.captionScale == b.captionScale &&
                        a.padding == b.padding && a.direction == b.direction && a.shape == b.shape
                }
                PlatePartKind.region -> {
                    val a = layout(from).leaves.getOrNull(i) ?: return false
                    val b = layout(to).leaves.getOrNull(i) ?: return false
                    val la = a.first as PlateSection.Leaf
                    val lb = b.first as PlateSection.Leaf
                    return a.second == b.second && la.shape == lb.shape && sameFill(la.fill, lb.fill) &&
                        (!la.fill.paintsPanel || from.country.panelColor == to.country.panelColor)
                }
                PlatePartKind.divider -> {
                    val a = layout(from).dividers.getOrNull(i)
                    return a != null && a == layout(to).dividers.getOrNull(i) && from.inkOverride == to.inkOverride
                }
                PlatePartKind.slot -> {
                    if (fromValues == null || toValues == null) return false
                    if (i >= from.slots.size || i >= to.slots.size || i >= fromValues.size || i >= toValues.size) return false
                    val a = from.slots[i]
                    val b = to.slots[i]
                    return (fromValues[i] ?: "") == (toValues[i] ?: "") && a.box == b.box && a.color == b.color &&
                        from.inkOverride == to.inkOverride
                }
                PlatePartKind.band -> {
                    if (i >= from.bands.size || i >= to.bands.size) return false
                    val a = from.bands[i]
                    val b = to.bands[i]
                    return a.box == b.box && a.color == b.color && a.topCornerRadius == b.topCornerRadius &&
                        a.bottomCornerRadius == b.bottomCornerRadius
                }
                PlatePartKind.rule -> {
                    if (i >= from.rules.size || i >= to.rules.size) return false
                    return from.rules[i].box == to.rules[i].box && from.inkOverride == to.inkOverride
                }
                PlatePartKind.label -> {
                    if (i >= from.labels.size || i >= to.labels.size) return false
                    val a = from.labels[i]
                    val b = to.labels[i]
                    return a.box == b.box && a.text == b.text && a.glyphHeight == b.glyphHeight && a.color == b.color &&
                        a.rotated == b.rotated && a.lineHeight == b.lineHeight && a.fontFamily == b.fontFamily &&
                        a.fontPackage == b.fontPackage
                }
                else -> return false
            }
        }

        private fun sameFill(a: PlateFill, b: PlateFill): Boolean {
            if (a === b) return true
            if (a is PlateFill.StripesFill || b is PlateFill.StripesFill) return false
            return a.field() == b.field() && a.panelled() == b.panelled() && a.tint() == b.tint()
        }

        private fun PlateFill.field() = this === PlateFill.Field
        private fun PlateFill.panelled() = this === PlateFill.Panel
        private fun PlateFill.tint() = (this as? PlateFill.ColorFill)?.color

        private fun layout(spec: PlateSpec<*>) =
            spec.background.layout(Rect.fromLTWH(0.0, 0.0, spec.canvasWidth, spec.canvasHeight))
    }
}

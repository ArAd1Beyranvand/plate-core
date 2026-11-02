package plates.render

import plates.core.theme.PlateTheme
import plates.core.theme.lerpColor
import plates.core.timing.PlatePartEffect
import plates.core.timing.PlatePartFrame
import plates.core.timing.PlatePartId
import plates.core.timing.PlatePartPhase
import plates.core.timing.plateRevealRect
import plates.core.values.Color
import plates.core.values.PlateFill
import plates.core.values.PlateSection
import plates.core.values.Rect
import plates.core.values.resolve
import kotlin.math.PI
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt
import kotlin.math.sin

/** Where every part is this frame. */
typealias Frames = (PlatePartId) -> PlatePartFrame

/** [D1] The outer rim, its inner edge, and the face the regions are clipped to. */
class FrameGeometry(val border: Double, val outerRadius: Double, val innerRadius: Double, val outer: RRect, val inner: RRect, val face: RRect)

fun frameGeometry(theme: PlateTheme, width: Double, height: Double, frames: Frames): FrameGeometry {
    val border = theme.borderWidthRatio * height * frames(PlatePartId.borderWidth).shown.coerceIn(0.0, 1.0)
    val outerRadius = theme.plateRadiusRatio * height * frames(PlatePartId.corner).shown.coerceIn(0.0, 1.0)
    val innerRadius = min(max(outerRadius - border, 0.0), outerRadius)
    val outer = RRect(Rect(0.0, 0.0, width, height), outerRadius)
    // Halfway into the border: the border's inner edge lies over a region, and a
    // region's edge never reaches the outer anti-aliased rim.
    return FrameGeometry(border, outerRadius, innerRadius, outer, RRect(deflate(outer.rect, border), innerRadius), deflateRRect(outer, border / 2))
}

/** Content bleeds this far under the border paint (PlateRimClip). */
fun rimClip(g: FrameGeometry) = RRect(deflate(g.outer.rect, max(0.0, g.border - 0.75)), g.innerRadius)

private val PlatePartFrame.fades get() = motion.effect != PlatePartEffect.wipe && motion.effect != PlatePartEffect.draw

private class FillColors(val field: Color, val panel: Color, val divider: Color)

private fun PlateFill.color(c: FillColors) = resolve(c.field, c.panel, c.divider)

/** [D1] PlateFrame: face, regions, dividers, border, in that order, each clipped to the face. */
fun paintFrame(
    c: DisplayList,
    theme: PlateTheme,
    width: Double,
    height: Double,
    background: PlateSection,
    panelColor: Color,
    isCompleted: Boolean,
    frames: Frames,
) {
    val g = frameGeometry(theme, width, height, frames)
    val bounds = Rect(0.0, 0.0, width, height)
    val layout = background.layout(bounds)
    val colors = FillColors(theme.plateBackground, panelColor, theme.dividerColor)

    val face = frames(PlatePartId.background)
    if (!face.hidden) {
        c.save()
        if (face.phase != PlatePartPhase.settled && !face.fades) c.clipRect(plateRevealRect(bounds, face.motion.origin, face))
        c.clipRRect(g.face)
        c.rrect(g.face, Paint(if (face.fades) withAlpha(theme.plateBackground, face.shown) else theme.plateBackground))
        c.restore()
    }

    for ((i, leaf) in layout.leaves.withIndex()) {
        val (section, r) = leaf
        val frame = frames(PlatePartId.region(i))
        if (frame.hidden || section !is PlateSection.Leaf || section.fill == PlateFill.Field) continue
        c.save()
        c.clipRRect(g.face)
        if (frame.phase != PlatePartPhase.settled && !frame.fades) c.clipRect(plateRevealRect(r, frame.motion.origin, frame))
        val opacity = if (frame.fades) frame.shown else 1.0
        val fill = section.fill
        if (fill is PlateFill.StripesFill) {
            paintStripes(c, fill, r, section.shape, opacity, colors)
        } else {
            val paint = Paint(withAlpha(fill.color(colors), opacity))
            if (section.shape == null) {
                c.rect(r, paint)
            } else {
                c.translate(r.left, r.top)
                c.path(section.shape, paint)
            }
        }
        c.restore()
    }

    for ((i, r) in layout.dividers.withIndex()) paintDivider(c, r, theme.dividerColor, frames(PlatePartId.divider(i)), g.face)

    paintBorder(c, theme, width, height, isCompleted, frames, g, bounds)
}

/** Each stripe a rect in a frame turned about [r]'s centre, clipped back to [r] (or its shape); then the fog. */
private fun paintStripes(c: DisplayList, fill: PlateFill.StripesFill, r: Rect, shape: String?, opacity: Double, colors: FillColors) {
    val cx = (r.left + r.right) / 2
    val cy = (r.top + r.bottom) / 2
    val reach = max(r.width, r.height)
    val angle = fill.angle
    c.save()
    if (shape == null) c.clipRect(r) else c.clipPath(shiftPath(shape, r.left, r.top))
    c.translate(cx, cy)
    c.rotate(-angle)
    var top = -reach
    // The Dart painter reuses one Paint: the fog keeps the last stripe's colour.
    var last: Color = 0xFF000000.toInt()
    for ((i, stripe) in fill.stripes.withIndex()) {
        // A stop is where the boundary meets the centreline: its perpendicular distance in the turned frame.
        val bottom = if (i < fill.stops.size) (fill.stops[i] - cy) * cos(angle) else reach
        if (stripe != PlateFill.Field) {
            last = withAlpha(stripe.color(colors), opacity)
            c.rect(Rect(-reach, top, reach, bottom), Paint(last))
        }
        top = bottom
    }
    c.restore()
    val fog = fill.fog ?: return
    c.save()
    c.clipRect(r)
    c.translate(fog.center.x, fog.center.y)
    c.scale(fog.radii.width, fog.radii.height)
    c.circle(0.0, 0.0, 1.0, Paint(last, shader = Fog(withAlpha(colors.field, fog.opacity * opacity), fog.plateau)))
    c.restore()
}

private val number = Regex("-?\\d+(\\.\\d+)?([eE]-?\\d+)?")

/** Shifts every coordinate pair of a `<rule>:<M/L/Z d>` path. */
fun shiftPath(path: String, dx: Double, dy: Double): String {
    val (rule, d) = path.split(':', limit = 2)
    var x = true
    return "$rule:" + number.replace(d) {
        val out = n4(it.value.toDouble() + if (x) dx else dy)
        x = !x
        out
    }
}

/** The ring's centreline, clockwise from the top-left corner, as sampled points with running lengths. */
private class Centreline(val xs: List<Double>, val ys: List<Double>, val at: List<Double>) {
    val length get() = at.last()

    fun point(s: Double): Pair<Double, Double> {
        var i = 1
        while (i < at.size - 1 && at[i] < s) i++
        val t = if (at[i] == at[i - 1]) 0.0 else (s - at[i - 1]) / (at[i] - at[i - 1])
        return (xs[i - 1] + (xs[i] - xs[i - 1]) * t) to (ys[i - 1] + (ys[i] - ys[i - 1]) * t)
    }

    /** [H13] The run between lengths [from] and [to], 0 <= from <= to <= length. */
    fun extract(from: Double, to: Double): String {
        val run = listOf(point(from)) + xs.indices.filter { at[it] > from && at[it] < to }.map { xs[it] to ys[it] } + listOf(point(to))
        return run.withIndex().joinToString(" ") { (i, p) -> "${if (i == 0) "M" else "L"}${n4(p.first)} ${n4(p.second)}" }
    }
}

private fun centreline(width: Double, height: Double, g: FrameGeometry): Centreline {
    val h = g.border / 2
    val l = h
    val t = h
    val rt = width - h
    val b = height - h
    val r = max(0.0, g.outerRadius - h)
    val xs = mutableListOf(l + r)
    val ys = mutableListOf(t)
    fun corner(cx: Double, cy: Double, from: Double) {
        val steps = max(1, ceil(r * PI / 2 / 0.25).toInt())
        for (i in 0..steps) {
            val a = from + PI / 2 * i / steps
            xs.add(cx + r * cos(a))
            ys.add(cy + r * sin(a))
        }
    }
    corner(rt - r, t + r, -PI / 2)
    corner(rt - r, b - r, 0.0)
    corner(l + r, b - r, PI / 2)
    corner(l + r, t + r, PI)
    val at = mutableListOf(0.0)
    for (i in 1 until xs.size) at.add(at[i - 1] + hypot(xs[i] - xs[i - 1], ys[i] - ys[i - 1]))
    return Centreline(xs, ys, at)
}

/** [H15] The completed border's tint: Color.lerp on 0..1 channels, so a half rounds as the doubles fall. */
private fun lerpUnit(a: Color, b: Color, t: Double): Color {
    var out = 0
    for (shift in intArrayOf(24, 16, 8, 0)) {
        val x = ((a ushr shift) and 0xFF) / 255.0
        val y = ((b ushr shift) and 0xFF) / 255.0
        out = out or (((x + (y - x) * t) * 255).roundToInt() shl shift)
    }
    return out
}

/** Settled: a filled ring. Drawing: a stroke along the centreline, grown from startPoint. */
private fun paintBorder(
    c: DisplayList, theme: PlateTheme, width: Double, height: Double, isCompleted: Boolean, frames: Frames, g: FrameGeometry, bounds: Rect,
) {
    val frame = frames(PlatePartId.border)
    if (frame.hidden) return
    val settled = if (isCompleted) lerpUnit(theme.plateBorder, theme.plateBackground, 0.02) else theme.plateBorder
    val shownColor = frames(PlatePartId.borderColor).shown.coerceIn(0.0, 1.0)
    val color = if (shownColor >= 1) settled else lerpColor(theme.plateBackground, settled, shownColor)
    val (a, b) = frame.span
    val whole = a <= 0 && b >= 1
    c.save()
    if (whole || frame.motion.effect != PlatePartEffect.draw) {
        if (whole || frame.fades) {
            c.drrect(g.outer, g.inner, Paint(if (whole || !frame.fades) color else withAlpha(color, frame.shown)))
        } else {
            c.save()
            c.clipRect(plateRevealRect(bounds, frame.motion.origin, frame))
            c.drrect(g.outer, g.inner, Paint(color))
            c.restore()
        }
        c.restore()
        return
    }
    val line = centreline(width, height, g)
    val length = line.length
    val s = ((frame.motion.startPoint % 1) + 1) % 1 * length
    val from = if (frame.motion.clockwise) s + a * length else s - b * length
    val to = if (frame.motion.clockwise) s + b * length else s - a * length
    val lo = ((from % length) + length) % length
    val span = to - from
    val d = if (lo + span <= length) line.extract(lo, lo + span) else "${line.extract(lo, length)} ${line.extract(0.0, lo + span - length)}"
    c.path("nonzero:$d", Paint(color, g.border, StrokeCap.butt, StrokeJoin.miter))
    c.restore()
}

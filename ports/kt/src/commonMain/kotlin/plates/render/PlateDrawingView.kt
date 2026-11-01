package plates.render

import plates.core.values.PlateCircleShape
import plates.core.values.PlateCrescentShape
import plates.core.values.PlateDrawing
import plates.core.values.PlatePolygonShape
import plates.core.values.PlateRectShape
import plates.core.values.PlateRingShape
import plates.core.values.PlateShape
import plates.core.values.PlateStarRingShape
import plates.core.values.PlateStarShape
import plates.core.values.Point
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.acos
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin

/** How a drawing meets its box: fill stretches it (a flag), contain keeps its proportions, centred (a decal). */
enum class DrawingFit { fill, contain }

private fun contour(pts: List<Point>) =
    pts.withIndex().joinToString(" ") { (i, p) -> "${if (i == 0) "M" else "L"}${n4(p.x)} ${n4(p.y)}" } + " Z"

/** [H13] A circle as a closed polyline from [from] radians (clockwise on screen) over [sweep], every 0.25 units. */
private fun arc(cx: Double, cy: Double, r: Double, from: Double = 0.0, sweep: Double = 2 * PI): List<Point> {
    val steps = min(4000, max(16, ceil(r * abs(sweep) / 0.25).toInt()))
    val full = abs(sweep) >= 2 * PI
    return List(if (full) steps else steps + 1) {
        val a = from + sweep * it / steps
        Point(cx + r * cos(a), cy + r * sin(a))
    }
}

private fun starPoints(cx: Double, cy: Double, radius: Double, points: Int, innerRatio: Double, rotation: Double): List<Point> {
    val turn = rotation * PI / 180
    return List(points * 2) {
        val r = if (it % 2 == 0) radius else radius * innerRatio
        val a = turn + PI * it / points
        Point(cx + r * sin(a), cy - r * cos(a))
    }
}

/** [H13] Disc minus bite (Path.combine difference, evenodd like Dart's result) as one outline. */
private fun crescent(cx: Double, cy: Double, r: Double, dx: Double, br: Double): String {
    val d = abs(dx)
    if (d >= r + br) return contour(arc(cx, cy, r))
    if (br >= d + r) return ""
    if (r >= d + br) return "${contour(arc(cx, cy, r))} ${contour(arc(cx + dx, cy, br))}"
    // Where the circles cross, as angles about each centre along +dx.
    val dir = if (dx >= 0) 0.0 else PI
    val a = acos((d * d + r * r - br * br) / (2 * d * r))
    val b = acos((d * d + br * br - r * r) / (2 * d * br))
    val bite = arc(cx + dx, cy, br, dir + PI + b, -2 * b)
    return contour(arc(cx, cy, r, dir + a, 2 * PI - 2 * a) + bite.subList(1, bite.size - 1))
}

/** [D1][H13] The shape as `<fillRule>:<SVG d>` in drawing units. */
fun shapePath(s: PlateShape): String = when (s) {
    is PlateRectShape -> "nonzero:" + contour(
        listOf(Point(s.left, s.top), Point(s.left + s.width, s.top), Point(s.left + s.width, s.top + s.height), Point(s.left, s.top + s.height)),
    )
    is PlatePolygonShape -> "nonzero:" + contour(s.points)
    is PlateCircleShape -> "nonzero:" + contour(arc(s.cx, s.cy, s.radius))
    is PlateRingShape ->
        "evenodd:${contour(arc(s.cx, s.cy, s.radius + s.width / 2))} ${contour(arc(s.cx, s.cy, max(0.0, s.radius - s.width / 2)))}"
    is PlateCrescentShape -> "evenodd:" + crescent(s.cx, s.cy, s.radius, s.biteDx, s.biteRadius)
    is PlateStarShape -> "nonzero:" + contour(starPoints(s.cx, s.cy, s.radius, s.points, s.innerRatio, s.rotation))
    is PlateStarRingShape -> "nonzero:" + (0 until s.count).joinToString(" ") {
        val a = 2 * PI * it / s.count
        contour(starPoints(s.cx + s.ringRadius * sin(a), s.cy - s.ringRadius * cos(a), s.starRadius, s.points, s.innerRatio, 0.0))
    }
}

/** [D6][H13] PlateDrawingView: paints [drawing] into a box of [width] x [height] at the current origin. */
fun paintDrawing(c: DisplayList, drawing: PlateDrawing, width: Double, height: Double, fit: DrawingFit = DrawingFit.fill) {
    val sx = width / drawing.width
    val sy = height / drawing.height
    val scaleX = if (fit == DrawingFit.contain) min(sx, sy) else sx
    val scaleY = if (fit == DrawingFit.contain) scaleX else sy
    c.save()
    c.translate((width - drawing.width * scaleX) / 2, (height - drawing.height * scaleY) / 2)
    c.scale(scaleX, scaleY)
    for (shape in drawing.shapes) c.path(shapePath(shape), Paint(shape.color))
    c.restore()
}

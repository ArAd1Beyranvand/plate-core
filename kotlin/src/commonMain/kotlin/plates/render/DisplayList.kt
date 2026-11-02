package plates.render

import plates.core.alphabet.TextDirection
import plates.core.values.Color
import plates.core.values.Rect
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.roundToInt
import kotlin.math.roundToLong
import kotlin.math.sin

/** [D1] x' = a·x + c·y + tx, y' = b·x + d·y + ty. */
data class Matrix(val a: Double, val b: Double, val c: Double, val d: Double, val tx: Double, val ty: Double) {
    operator fun times(q: Matrix) = Matrix(
        a * q.a + c * q.b, b * q.a + d * q.b,
        a * q.c + c * q.d, b * q.c + d * q.d,
        a * q.tx + c * q.ty + tx, b * q.tx + d * q.ty + ty,
    )

    fun toList() = listOf(a, b, c, d, tx, ty)

    companion object {
        val identity = Matrix(1.0, 0.0, 0.0, 1.0, 0.0, 0.0)
    }
}

/** A rounded rect: [radii] are `tl.x, tl.y, tr.x, tr.y, br.x, br.y, bl.x, bl.y`. */
data class RRect(val rect: Rect, val radii: List<Double>) {
    /** One radius at every corner. */
    constructor(rect: Rect, radius: Double) : this(rect, List(8) { max(0.0, radius) })

    val radius get() = radii[0]
}

/** A radial fog: centre alpha, plateau stop, edge transparent (see the region painter). */
data class Fog(val color: Color, val plateau: Double)

enum class StrokeCap { butt, round, square }

enum class StrokeJoin { miter, round, bevel }

data class Paint(
    val color: Color,
    val stroke: Double? = null,
    val cap: StrokeCap? = null,
    val join: StrokeJoin? = null,
    val shader: Fog? = null,
)

data class TextStyle(
    val fontSize: Double,
    val height: Double,
    val color: Color,
    val fontFamily: String,
    val fontWeight: Int,
    val letterSpacing: Double,
)

enum class TextAlign { start, center }

/** What one display-list op draws, the shape of ports/vectors/render. Paths are `<fillRule>:<SVG d>`. */
sealed interface Draw {
    object Save : Draw
    object Restore : Draw
    data class Layer(val bounds: Rect?, val paint: Paint) : Draw
    data class ClipRect(val rect: Rect) : Draw
    data class ClipRRect(val rrect: RRect) : Draw
    data class ClipPath(val path: String) : Draw
    data class RectOp(val rect: Rect, val paint: Paint) : Draw
    data class RRectOp(val rrect: RRect, val paint: Paint) : Draw
    data class DRRect(val outer: RRect, val inner: RRect, val paint: Paint) : Draw
    data class PathOp(val path: String, val paint: Paint) : Draw
    data class Circle(val cx: Double, val cy: Double, val radius: Double, val paint: Paint) : Draw
    data class Text(val text: String, val box: Rect, val align: TextAlign, val direction: TextDirection, val style: TextStyle, val alphas: List<Double>? = null) : Draw

    /** [kind] is "svg" or "raster". */
    data class Asset(val kind: String, val `package`: String, val path: String, val box: Rect) : Draw
}

/** One op with the transform [m] that maps its local geometry to plate units. */
data class DisplayOp(val m: Matrix, val draw: Draw)

fun deflate(r: Rect, d: Double) = Rect(r.left + d, r.top + d, r.right - d, r.bottom - d)

fun deflateRRect(r: RRect, d: Double) = RRect(deflate(r.rect, d), r.radius - d)

/** [D1] A canvas that keeps every call with the transform it ran under, as the Dart Recorder does. */
class DisplayList {
    val ops = mutableListOf<DisplayOp>()
    private val stack = mutableListOf(Matrix.identity)

    val matrix get() = stack.last()

    private fun add(draw: Draw) {
        ops.add(DisplayOp(matrix, draw))
    }

    fun save() {
        add(Draw.Save)
        stack.add(matrix)
    }

    fun layer(bounds: Rect?, opacity: Double) {
        add(Draw.Layer(bounds, Paint((opacity * 255).roundToInt() shl 24)))
        stack.add(matrix)
    }

    fun restore() {
        stack.removeAt(stack.size - 1)
        add(Draw.Restore)
    }

    fun transform(t: Matrix) {
        stack[stack.size - 1] = matrix * t
    }

    fun translate(dx: Double, dy: Double) {
        if (dx != 0.0 || dy != 0.0) transform(Matrix(1.0, 0.0, 0.0, 1.0, dx, dy))
    }

    fun scale(sx: Double, sy: Double = sx) {
        if (sx != 1.0 || sy != 1.0) transform(Matrix(sx, 0.0, 0.0, sy, 0.0, 0.0))
    }

    fun rotate(radians: Double) {
        val c = cos(radians)
        val s = sin(radians)
        transform(Matrix(c, s, -s, c, 0.0, 0.0))
    }

    fun clipRect(r: Rect) = add(Draw.ClipRect(r))
    fun clipRRect(r: RRect) = add(Draw.ClipRRect(r))
    fun clipPath(path: String) = add(Draw.ClipPath(path))
    fun rect(r: Rect, paint: Paint) = add(Draw.RectOp(r, paint))
    fun rrect(r: RRect, paint: Paint) = add(Draw.RRectOp(r, paint))
    fun drrect(outer: RRect, inner: RRect, paint: Paint) = add(Draw.DRRect(outer, inner, paint))
    fun path(path: String, paint: Paint) = add(Draw.PathOp(path, paint))
    fun circle(cx: Double, cy: Double, radius: Double, paint: Paint) = add(Draw.Circle(cx, cy, radius, paint))
    fun text(text: String, box: Rect, align: TextAlign, direction: TextDirection, style: TextStyle, alphas: List<Double>? = null) =
        add(Draw.Text(text, box, align, direction, style, alphas))
    fun asset(kind: String, `package`: String, path: String, box: Rect) = add(Draw.Asset(kind, `package`, path, box))
}

/** [H15] Flutter's `withValues(alpha: a * f)`: the alpha channel scaled, rounded. */
fun withAlpha(c: Color, f: Double): Color {
    if (f >= 1) return c
    val a = (((c ushr 24) and 0xFF) * max(0.0, f)).roundToInt()
    return (a shl 24) or (c and 0xFFFFFF)
}

/** Rounds to four places, as path data is written. */
internal fun n4(v: Double): String {
    val r = (v * 1e4).roundToLong() / 1e4
    return if (r == r.toLong().toDouble()) r.toLong().toString() else r.toString()
}

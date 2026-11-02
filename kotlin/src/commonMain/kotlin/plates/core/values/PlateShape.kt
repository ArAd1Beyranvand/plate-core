package plates.core.values

const val PENTAGRAM_RATIO = 0.3819660112501051

/**
 * One filled shape of a PlateDrawing, in the drawing's own coordinate space.
 * Shapes paint in list order, so a later one covers an earlier one. Path
 * building lives in render.
 */
sealed interface PlateShape {
    val color: Color
}

data class PlateRectShape(
    val left: Double, val top: Double, val width: Double, val height: Double, override val color: Color,
) : PlateShape

data class PlatePolygonShape(val points: List<Point>, override val color: Color) : PlateShape

data class PlateCircleShape(
    val cx: Double, val cy: Double, val radius: Double, override val color: Color,
) : PlateShape

/** The outline of a circle: a band [width] wide centred on [radius]. */
data class PlateRingShape(
    val cx: Double, val cy: Double, val radius: Double, val width: Double, override val color: Color,
) : PlateShape

/**
 * A circle with a second circle taken out of it: a crescent. The bite is
 * [biteRadius] wide and sits [biteDx] to the right of the disc's centre (left
 * when negative).
 */
data class PlateCrescentShape(
    val cx: Double, val cy: Double, val radius: Double, val biteDx: Double, val biteRadius: Double,
    override val color: Color,
) : PlateShape

/**
 * A regular star. [rotation] turns it clockwise, in degrees, from one point
 * straight up. [innerRatio] is the inner radius over [radius].
 */
data class PlateStarShape(
    val cx: Double, val cy: Double, val radius: Double, override val color: Color,
    val points: Int = 5, val innerRatio: Double = PENTAGRAM_RATIO, val rotation: Double = 0.0,
) : PlateShape

/**
 * [count] equal stars on a circle of [ringRadius], the first straight above
 * the centre and the rest clockwise from it, each one upright.
 */
data class PlateStarRingShape(
    val cx: Double, val cy: Double, val ringRadius: Double, val starRadius: Double, val count: Int,
    override val color: Color, val points: Int = 5, val innerRatio: Double = PENTAGRAM_RATIO,
) : PlateShape

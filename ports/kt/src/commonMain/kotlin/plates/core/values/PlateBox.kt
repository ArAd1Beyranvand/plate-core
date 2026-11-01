package plates.core.values

/** A plain rectangle; the one Rect type of the model. */
data class Rect(val left: Double, val top: Double, val right: Double, val bottom: Double) {
    val width get() = right - left
    val height get() = bottom - top

    companion object {
        fun fromLTRB(left: Double, top: Double, right: Double, bottom: Double) = Rect(left, top, right, bottom)

        fun fromLTWH(left: Double, top: Double, width: Double, height: Double) =
            Rect(left, top, left + width, top + height)
    }
}

/** A point in a drawing's coordinate space. */
data class Point(val x: Double, val y: Double)

/** Colors are ARGB32 ints. */
typealias Color = Int

fun Color(argb: Long): Color = argb.toInt()

/**
 * A rectangle in plate coordinates: origin at the plate's top-left, units
 * shared with PlateSpec.canvasWidth and canvasHeight.
 */
data class PlateBox(val left: Double, val top: Double, val width: Double, val height: Double) {
    val right get() = left + width
    val bottom get() = top + height
    val rect get() = Rect.fromLTWH(left, top, width, height)
}

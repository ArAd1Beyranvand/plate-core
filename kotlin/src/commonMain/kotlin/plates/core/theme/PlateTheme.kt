package plates.core.theme

import plates.core.values.Color
import kotlin.math.roundToInt

/** Glyph text style in canvas px: fontSize = slotHeight * 0.72, line height 1, bold (H12). */
data class GlyphStyle(val color: Color, val fontSize: Double, val letterSpacing: Double = 0.0, val fontWeight: Int = 700)

/**
 * Chrome colours and ratios, sampled from real plates; never tint them with a
 * host accent. Only [activeColor] and [inactiveColor], used solely for
 * input-mode outlines, are chrome-free. The `*Ratio` fields are fractions of
 * the plate height. Structural equality is right here (H15); the UI passes the
 * theme explicitly, there is no ambient scope (H14).
 */
data class PlateTheme(
    val plateBackground: Color,
    val plateBorder: Color,
    val ink: Color,
    val dividerColor: Color,
    val borderWidthRatio: Double,
    val plateRadiusRatio: Double,
    /** Outline of a completed input field. */
    val activeColor: Color,
    /** Outline of an empty or in-progress input field. */
    val inactiveColor: Color,
    /** Outline painted when validating an invalid plate. */
    val alertColor: Color = DEFAULT_ALERT,
) {
    fun glyphStyle(slotHeight: Double, color: Color, letterSpacing: Double = 0.0) =
        GlyphStyle(color, slotHeight * 0.72, letterSpacing)

    companion object {
        const val DEFAULT_ALERT: Color = 0xFFF87171.toInt()

        /** White face, black frame. */
        fun standard() = PlateTheme(
            plateBackground = 0xFFFFFFFF.toInt(),
            plateBorder = 0xFF000000.toInt(),
            ink = 0xFF0A0A0A.toInt(),
            dividerColor = 0xFF000000.toInt(),
            borderWidthRatio = 0.04,
            plateRadiusRatio = 0.12,
            activeColor = 0xFF0A0A0A.toInt(),
            inactiveColor = 0x66666666,
        )

        /** A plate printed in one [ink] on one [field]; [inactive] is input chrome only. */
        fun monochrome(
            field: Color,
            ink: Color,
            inactive: Color,
            borderWidthRatio: Double,
            plateRadiusRatio: Double,
            alertColor: Color = DEFAULT_ALERT,
        ) = PlateTheme(field, ink, ink, ink, borderWidthRatio, plateRadiusRatio, ink, inactive, alertColor)

        /** Every field interpolated, for the theme cross-fade (H15). */
        fun lerp(a: PlateTheme, b: PlateTheme, t: Double) = PlateTheme(
            lerpColor(a.plateBackground, b.plateBackground, t),
            lerpColor(a.plateBorder, b.plateBorder, t),
            lerpColor(a.ink, b.ink, t),
            lerpColor(a.dividerColor, b.dividerColor, t),
            lerpDouble(a.borderWidthRatio, b.borderWidthRatio, t),
            lerpDouble(a.plateRadiusRatio, b.plateRadiusRatio, t),
            lerpColor(a.activeColor, b.activeColor, t),
            lerpColor(a.inactiveColor, b.inactiveColor, t),
            lerpColor(a.alertColor, b.alertColor, t),
        )
    }
}

fun lerpDouble(a: Double, b: Double, t: Double) = a + (b - a) * t

/** Per-channel ARGB32 interpolation, rounded like Flutter's Color.lerp. */
fun lerpColor(a: Color, b: Color, t: Double): Color {
    var out = 0
    for (shift in intArrayOf(24, 16, 8, 0)) {
        val x = (a ushr shift) and 0xFF
        val y = (b ushr shift) and 0xFF
        out = out or (lerpDouble(x.toDouble(), y.toDouble(), t).roundToInt().coerceIn(0, 255) shl shift)
    }
    return out
}

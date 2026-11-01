package plates.countries.iran

import plates.core.theme.PlateTheme

/** The colour schemes an Iranian plate is printed in; the constants are generated in Themes.kt. */
object IranThemes {
    /** PlateSpec.resolveTheme for IranPlates.civil: the series letter's class colours on [base]'s rim and corner. */
    fun civil(base: PlateTheme, group: (String) -> String): PlateTheme {
        val t = when (group("letter")) {
            "ت", "ع", "ک" -> blackOnYellow
            "الف" -> whiteOnRed
            "پ", "ث" -> whiteOnGreen
            "ش" -> blackOnTan
            "ز", "ف" -> whiteOnForcesBlue
            "D", "S" -> blackOnCyan
            else -> blackOnWhite
        }
        return base.copy(
            plateBackground = t.plateBackground,
            plateBorder = t.plateBorder,
            ink = t.ink,
            dividerColor = t.dividerColor,
            activeColor = t.activeColor,
            inactiveColor = t.inactiveColor,
        )
    }
}

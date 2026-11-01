package plates.countries.iranshahr

import plates.core.theme.PlateTheme

/** The themes themselves are generated (`Themes.kt`); only the resolver is code. */
object AfghanistanThemes {
    fun byClass(base: PlateTheme, group: (String) -> String): PlateTheme {
        val t = when (group("class")) {
            "T", "B" -> transport
            else -> civilian
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

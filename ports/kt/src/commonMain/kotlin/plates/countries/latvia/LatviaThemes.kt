package plates.countries.latvia

import plates.core.theme.PlateTheme

/** The themes themselves are generated (`Themes.kt`); only the resolver is code. */
object LatviaThemes {
    fun byLetters(base: PlateTheme, group: (String) -> String): PlateTheme = when (group("letters")) {
        "TX", "TQ" -> taxi
        "EX" -> electric
        else -> base
    }
}

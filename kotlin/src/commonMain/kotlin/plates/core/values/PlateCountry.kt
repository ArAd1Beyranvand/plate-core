package plates.core.values

/** The country chrome of a plate. Equal iff the codes match. Colours are ARGB. */
class PlateCountry(
    /** ISO 3166-1 alpha-2, lower-case. */
    val code: String,
    val captionLines: List<String>,
    val panelColor: Color,
    /** Null prints the wording in the theme's ink. */
    val panelTextColor: Color?,
    val headingLines: List<String> = emptyList(),
    val flagAspectRatio: Double = 7.0 / 4,
    val flag: PlateGraphic? = null,
    val flagBorderColor: Color? = null,
) {
    override fun equals(other: Any?) = other is PlateCountry && other.code == code

    override fun hashCode() = code.hashCode()
}

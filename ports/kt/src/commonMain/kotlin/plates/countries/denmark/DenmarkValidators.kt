package plates.countries.denmark

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isLetters

private val vanity = Regex("^[A-ZÆØÅ0-9]{2,7}$")

/** Judges a Danish serial plate field by field. [allowedLetters] narrows the letters, as Greenland's GR and GL. */
class DenmarkValidator(
    val yearDigits: Int = 0,
    val midDigits: Int = 2,
    val numberDigits: Int = 3,
    val allowedLetters: Set<String>? = null,
) : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val letters = entry.group("letters")
        val hasLetters = yearDigits == 0
        if (hasLetters && !isLetters(letters, 2)) return PlateValidation.invalid(REASON_LETTERS)
        if (hasLetters && allowedLetters != null && letters !in allowedLetters) {
            return PlateValidation.invalid(REASON_GREENLAND)
        }
        if ((yearDigits > 0 && !isDigitsOfLength(entry.group("year"), yearDigits)) ||
            (midDigits > 0 && !isDigitsOfLength(entry.group("mid"), midDigits)) ||
            !isDigitsOfLength(entry.group("number"), numberDigits)
        ) {
            return PlateValidation.invalid(REASON_DIGITS)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The letters are two of A–Z."
        const val REASON_GREENLAND = "Greenland uses the letters GR or GL."
        const val REASON_DIGITS = "The digits do not fit the plate."

        fun greenland() = DenmarkValidator(allowedLetters = setOf("GR", "GL"))
        fun fixedTemporary() = DenmarkValidator(midDigits = 0, numberDigits = 2)
        fun faroeIslands() = DenmarkValidator(midDigits = 0)
        fun exportTemporary() = DenmarkValidator(yearDigits = 2)
    }
}

/** Judges a vanity plate: two to seven letters or digits, with Æ, Ø and Å. */
class DenmarkVanityValidator : GatedPlateValidator() {
    override val gateGroup = "text"

    override fun judge(entry: PlateEntry) =
        if (vanity.matches(entry.group("text"))) PlateValidation.valid else PlateValidation.invalid(REASON_TEXT)

    companion object {
        const val REASON_TEXT = "A vanity plate is two to seven letters or digits."
    }
}

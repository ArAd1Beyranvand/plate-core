package plates.countries.pakistan

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

private val letters = Regex("^[A-HJ-NP-TV-Z]{2,3}$")

/**
 * Judges a Pakistani registration: two or three letters (none of I, O, U), three or four digits, and on Punjab's plate a two-digit year. Reports, never bars a keystroke.
 */
class PakistanValidator : GatedPlateValidator() {
    override val gateGroup = "digits"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        val digits = entry.group("digits")
        if (!isDigits(digits) || digits.length < 3 || digits.length > 4) return PlateValidation.invalid(REASON_DIGITS)
        val year = entry.group("year")
        if (year.isNotEmpty() && !isDigitsOfLength(year, 2)) return PlateValidation.invalid(REASON_YEAR)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The letters are two or three, none of I, O, U."
        const val REASON_DIGITS = "The number is three or four digits."
        const val REASON_YEAR = "The year is two digits."
    }
}

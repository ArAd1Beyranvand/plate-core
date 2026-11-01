package plates.countries.andorra

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/**
 * Judges an Andorran plate by its groups. Reports, never bars a keystroke.
 *
 * A standard plate is one letter and four digits (`L 3705`). A temporary plate
 * is `MT`, four digits and an expiry month (a Roman numeral, I to XII) and
 * two-digit year.
 */
class AndorraValidator : GatedPlateValidator() {
    override val gateGroup = "digits"

    override fun judge(entry: PlateEntry): PlateValidation {
        val digits = entry.group("digits")
        val month = entry.group("month")
        val year = entry.group("year")
        if (month.isNotEmpty() || year.isNotEmpty()) {
            return if (isDigitsOfLength(digits, 4) && MONTH.matches(month) && isDigitsOfLength(year, 2)) {
                PlateValidation.valid
            } else {
                PlateValidation.invalid(REASON_TEMPORARY)
            }
        }
        return if (isDigitsOfLength(digits, 4) && LETTER.matches(entry.group("letter"))) {
            PlateValidation.valid
        } else {
            PlateValidation.invalid(REASON_STANDARD)
        }
    }

    companion object {
        const val REASON_STANDARD = "A plate is one letter and four digits."
        const val REASON_TEMPORARY = "A temporary plate is four digits, a month (I to XII) and a year."

        private val MONTH = Regex("^(I{1,3}|IV|IX|VI{0,3}|XI{0,2})$")
        private val LETTER = Regex("^[A-Z]$")
    }
}

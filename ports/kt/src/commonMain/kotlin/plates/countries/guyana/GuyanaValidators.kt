package plates.countries.guyana

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

private val lettersRe = Regex("^[A-Z]{2,3}$")
private val numberRe = Regex("^[1-9][0-9]{0,3}$")

/** Judges a standard Guyanese registration: a series of two or three letters, then one to four digits without a leading zero. Reports, never bars a keystroke. */
class GuyanaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry) = validateFields(entry.group("letters"), entry.group("number"))

    companion object {
        const val MIN_LETTERS = 2
        const val MAX_LETTERS = 3
        const val MAX_DIGITS = 4

        const val REASON_LETTERS = "The series is two or three letters."
        const val REASON_NUMBER = "The number is one to four digits, with no leading zero."

        fun validateFields(letters: String, number: String): PlateValidation {
            if (!lettersRe.matches(letters)) return PlateValidation.invalid(REASON_LETTERS)
            if (!numberRe.matches(number)) return PlateValidation.invalid(REASON_NUMBER)
            return PlateValidation.valid
        }
    }
}

/** What the first letter of a series stands for, from the article. */
object GuyanaVehicleTypes {
    val names = mapOf(
        "P" to "Private",
        "H" to "Hire / taxi",
        "B" to "Bus",
        "G" to "Goods (powered trade vehicle)",
        "C" to "Cycle",
        "T" to "Trailer (non-powered trade vehicle)",
    )
}

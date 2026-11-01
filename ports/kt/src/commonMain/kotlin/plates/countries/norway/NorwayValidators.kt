package plates.countries.norway

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

private val prefix = Regex("^[ABCDEFHJKLNPRSTUVWXYZ]{2}$")

/**
 * Judges a Norwegian plate. A regular plate is two letters and four or five digits (`AB 12345`); a diplomatic plate is `CD`, a two-digit mission code and a three-digit sequence. Reports, never bars a keystroke; the one refusal is the restriction the diplomatic spec carries.
 */
class NorwayValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val code = entry.group("code")
        if (code.isNotEmpty()) {
            if (code != "CD") return PlateValidation.invalid(REASON_CODE)
            if (!isDigitsOfLength(entry.group("embassy"), 2)) return PlateValidation.invalid(REASON_EMBASSY)
            if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_CAR)
            return PlateValidation.valid
        }
        if (!prefix.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        val number = entry.group("number")
        if (!isDigits(number) || number.length < 4 || number.length > 5) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The prefix is two letters (no G, I, M, O, Q)."
        const val REASON_NUMBER = "The number is four or five digits."
        const val REASON_CODE = "The prefix is CD."
        const val REASON_EMBASSY = "The mission code is two digits."
        const val REASON_CAR = "The sequence is three digits."
    }
}

package plates.countries.finland

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

private val lettersPattern = Regex("^[A-ZÅÄÖ]+$")

/**
 * Judges a Finnish plate, field by field: regular (2-3 letters, 1-3 digits not starting with 0), Åland (`ÅL`, up to
 * five digits), export (one letter, up to four) and diplomatic (`CD` up to four, `C` up to five). Reports, never bars a keystroke.
 */
class FinlandValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val number = entry.group("number")
        val code = entry.group("code")
        if (code.isNotEmpty()) {
            if (code != "C" && code != "CD") return PlateValidation.invalid(REASON_CODE)
            val max = if (code == "C") 5 else 4
            if (!isDigits(number) || number.length > max) return PlateValidation.invalid(REASON_DIPLOMATIC)
            return PlateValidation.valid
        }
        val letters = entry.group("letters")
        if (!lettersPattern.matches(letters)) return PlateValidation.invalid(REASON_LETTERS)
        if (letters.length == 1) {
            if (!isDigits(number) || number.length > 4) return PlateValidation.invalid(REASON_EXPORT)
            return PlateValidation.valid
        }
        if (letters.length > 3) return PlateValidation.invalid(REASON_LETTERS)
        if (letters.startsWith("ÅL")) {
            if (!isDigits(number) || number.length > 5) return PlateValidation.invalid(REASON_ALAND)
            return PlateValidation.valid
        }
        if (!isDigits(number) || number.length > 3 || number.startsWith("0")) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The letters are two or three of A–Z, Å, Ä, Ö."
        const val REASON_NUMBER = "The number is one to three digits, not starting with 0."
        const val REASON_ALAND = "The Åland number is up to five digits."
        const val REASON_EXPORT = "The export number is up to four digits."
        const val REASON_CODE = "The prefix is C or CD."
        const val REASON_DIPLOMATIC = "CD takes up to four digits, C up to five."
    }
}

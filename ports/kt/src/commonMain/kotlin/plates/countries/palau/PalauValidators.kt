package plates.countries.palau

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength
import plates.core.validators.restrictionVerdict

private val letters = Regex("^[A-Z]{1,3}$")
private val serial = Regex("^[A-Z0-9]{1,8}$")

/** Judges a Palauan registration. Reports, never bars a keystroke. */
class PalauValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val digits = entry.group("digits")
        val ser = entry.group("serial")
        if (digits.isEmpty() && ser.isEmpty()) return PlateValidation.valid
        val lt = entry.group("letters")
        if (lt.isNotEmpty() && !letters.matches(lt)) return PlateValidation.invalid(REASON_LETTERS)
        val code = entry.group("code")
        if (code.isNotEmpty() && !isDigitsOfLength(code, 2)) return PlateValidation.invalid(REASON_CODE)
        if (digits.isNotEmpty() && (!isDigits(digits) || digits.length > 5)) return PlateValidation.invalid(REASON_DIGITS)
        if (ser.isNotEmpty() && !serial.matches(ser)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The letters are one to three capitals."
        const val REASON_CODE = "The code is two digits."
        const val REASON_DIGITS = "The number is one to five digits."
        const val REASON_SERIAL = "The serial is up to eight letters and digits."
    }
}

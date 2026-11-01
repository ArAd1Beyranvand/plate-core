package plates.countries.tanzania

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val code = Regex("^[23][0-9]{2}$")
private val letters = Regex("^[A-Z]{3}$")

/** A fixed `T`, three digits, three letters; the organisation plate is `T`, a code (200 to 399), `CD` and a three-digit number. Reports, never bars a keystroke. */
class TanzaniaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("organisation").isNotEmpty()) {
            if (!code.matches(entry.group("organisation"))) return PlateValidation.invalid(REASON_CODE)
            if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_CAR)
            return PlateValidation.valid
        }
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_NUMBER)
        if (!letters.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is three digits."
        const val REASON_LETTERS = "The series is three letters."
        const val REASON_CODE = "The organisation code is 200 to 399."
        const val REASON_CAR = "The car number is three digits."
    }
}

package plates.countries.jamaica

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters = Regex("^[A-Z]{1,2}$")

/** Judges a Jamaican private registration: a `serial` of four digits and `letters` of one to two. Reports, never bars a keystroke. */
class JamaicaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) = validateFields(entry.group("serial"), entry.group("letters"))

    companion object {
        const val REASON_SERIAL = "The serial is four digits."
        const val REASON_LETTERS = "The series is one or two letters."

        fun validateFields(serial: String, letters: String): PlateValidation {
            if (!isDigitsOfLength(serial, 4)) return PlateValidation.invalid(REASON_SERIAL)
            if (!plates.countries.jamaica.letters.matches(letters)) return PlateValidation.invalid(REASON_LETTERS)
            return PlateValidation.valid
        }
    }
}

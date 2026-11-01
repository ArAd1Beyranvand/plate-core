package plates.countries.syria

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letterRe = Regex("^[A-Z]$")

/** A two-digit code and a five-digit serial; no code table is published, so any two digits pass. */
class SyriaTransitionalValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) = validateFields(entry.group("code"), entry.group("serial"))

    companion object {
        const val REASON_CODE = "The code is two digits."
        const val REASON_SERIAL = "The serial is five digits."

        fun validateFields(code: String, serial: String): PlateValidation {
            if (!isDigitsOfLength(code, 2)) return PlateValidation.invalid(REASON_CODE)
            if (!isDigitsOfLength(serial, 5)) return PlateValidation.invalid(REASON_SERIAL)
            return PlateValidation.valid
        }
    }
}

/** Six digits, printed twice. */
class AanesValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) = validateFields(entry.group("serial"))

    companion object {
        const val REASON_SERIAL = "The number is six digits."

        fun validateFields(serial: String) =
            if (isDigitsOfLength(serial, 6)) PlateValidation.valid else PlateValidation.invalid(REASON_SERIAL)
    }
}

/** One Latin letter and four digits. */
class AanesMotorcycleValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) = validateFields(entry.group("letter"), entry.group("serial"))

    companion object {
        const val REASON_LETTER = "A motorcycle plate starts with a letter."
        const val REASON_SERIAL = "The number is four digits."

        fun validateFields(letter: String, serial: String): PlateValidation {
            if (!letterRe.matches(letter)) return PlateValidation.invalid(REASON_LETTER)
            if (!isDigitsOfLength(serial, 4)) return PlateValidation.invalid(REASON_SERIAL)
            return PlateValidation.valid
        }
    }
}

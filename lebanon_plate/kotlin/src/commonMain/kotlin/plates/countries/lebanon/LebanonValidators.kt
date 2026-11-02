package plates.countries.lebanon

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

private val letterCodes = setOf("A", "B", "Y", "G", "N", "O", "S", "T", "K", "Z", "J", "R", "M", "C", "D", "P", "MP")

/** Advisory validator; never bars a keystroke. Waits for a non-empty serial. */
class LebanonValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) = validateFields(entry.group("letter"), entry.group("serial"))

    companion object {
        const val REASON_LETTER_MISSING = "A plate starts with a letter."
        const val REASON_LETTER_UNKNOWN = "That is not a Lebanese plate letter."
        const val REASON_SERIAL_NOT_NUMERIC = "The number is digits only."
        const val REASON_SERIAL_LENGTH = "The number is one to six digits."
        const val REASON_PARLIAMENT_RANGE = "A parliament plate is numbered 1 to 128."
        const val MIN_SERIAL_LENGTH = 1
        const val MAX_SERIAL_LENGTH = 6
        const val MAX_PARLIAMENT_NUMBER = 128

        fun validateFields(letter: String, serial: String): PlateValidation {
            if (letter.isEmpty()) return PlateValidation.invalid(REASON_LETTER_MISSING)
            val code = letter.uppercase()
            if (code !in letterCodes) return PlateValidation.invalid(REASON_LETTER_UNKNOWN)
            if (serial.length < MIN_SERIAL_LENGTH || serial.length > MAX_SERIAL_LENGTH) {
                return PlateValidation.invalid(REASON_SERIAL_LENGTH)
            }
            if (!isDigits(serial)) return PlateValidation.invalid(REASON_SERIAL_NOT_NUMERIC)
            if (code == "MP") {
                val number = serial.toInt()
                if (number < 1 || number > MAX_PARLIAMENT_NUMBER) return PlateValidation.invalid(REASON_PARLIAMENT_RANGE)
            }
            return PlateValidation.valid
        }
    }
}

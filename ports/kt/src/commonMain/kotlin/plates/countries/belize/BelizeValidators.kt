package plates.countries.belize

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isLetters

/** Judges a Belizean registration: an optional one-to-three-letter `prefix` and a three-to-five-digit `serial`. Reports, never bars a keystroke. */
class BelizeValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation =
        validateFields(entry.group("prefix"), entry.group("serial"))

    companion object {
        const val MIN_SERIAL = 3
        const val MAX_SERIAL = 5
        const val MAX_PREFIX = 3

        const val REASON_SERIAL = "The serial is three to five digits."
        const val REASON_PREFIX = "The prefix is one to three letters."

        fun validateFields(prefix: String, serial: String): PlateValidation {
            if (prefix.isNotEmpty() && !isLetters(prefix, 1, 3)) {
                return PlateValidation.invalid(REASON_PREFIX)
            }
            if (!isDigits(serial) || serial.length < MIN_SERIAL || serial.length > MAX_SERIAL) {
                return PlateValidation.invalid(REASON_SERIAL)
            }
            return PlateValidation.valid
        }
    }
}

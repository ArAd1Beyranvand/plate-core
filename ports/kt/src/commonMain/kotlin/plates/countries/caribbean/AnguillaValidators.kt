package plates.countries.caribbean

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

private val typeLetter = Regex("^[A-Z]$")

/** Judges an `AnguillaPlates.private` value: a vehicle-type letter and one to four digits (`A 1234`). */
class AnguillaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) = validateFields(entry.group("type"), entry.group("serial"))

    companion object {
        const val MAX_DIGITS = 4

        const val REASON_TYPE = "The plate starts with a type letter."
        const val REASON_SERIAL = "The serial is one to four digits."

        fun validateFields(type: String, serial: String): PlateValidation {
            if (!typeLetter.matches(type)) return PlateValidation.invalid(REASON_TYPE)
            if (!isDigits(serial) || serial.length > MAX_DIGITS) return PlateValidation.invalid(REASON_SERIAL)
            return PlateValidation.valid
        }
    }
}

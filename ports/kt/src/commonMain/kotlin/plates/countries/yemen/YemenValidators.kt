package plates.countries.yemen

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

// YemenGovernorate.minCode / maxCode.
private const val MIN_GOVERNORATE = 1
private const val MAX_GOVERNORATE = 22

/** Judges a System A (2026 unified) plate, gated on the side code. The side code is checked for shape only. */
class YemenUnifiedValidator : GatedPlateValidator() {
    override val gateGroup = "sideCode"

    override fun judge(entry: PlateEntry): PlateValidation =
        validateFields(entry.group("number"), entry.group("sideCode"))

    companion object {
        const val REASON_NUMBER_NOT_NUMERIC = "The vehicle number is digits only."
        const val REASON_NUMBER_LENGTH = "The vehicle number is four to six digits."
        const val REASON_SIDE_CODE_NOT_NUMERIC = "The side code is digits only."
        const val REASON_SIDE_CODE_LENGTH = "The side code is two digits."
        const val MIN_NUMBER_LENGTH = 4
        const val MAX_NUMBER_LENGTH = 6

        fun validateFields(number: String, sideCode: String): PlateValidation {
            if (number.isNotEmpty() && !isDigits(number)) {
                return PlateValidation.invalid(REASON_NUMBER_NOT_NUMERIC)
            }
            if (number.length < MIN_NUMBER_LENGTH || number.length > MAX_NUMBER_LENGTH) {
                return PlateValidation.invalid(REASON_NUMBER_LENGTH)
            }
            if (!isDigits(sideCode)) return PlateValidation.invalid(REASON_SIDE_CODE_NOT_NUMERIC)
            if (sideCode.length != 2) return PlateValidation.invalid(REASON_SIDE_CODE_LENGTH)
            return PlateValidation.valid
        }
    }
}

/** Judges a System B (1993 northern) plate, gated on the serial: governorate 1..22, serial never zero-padded. */
class YemenNorthernValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation =
        validateFields(entry.group("governorate"), entry.group("serial"))

    companion object {
        const val REASON_GOVERNORATE_NOT_NUMERIC = "The governorate code is digits only."
        const val REASON_GOVERNORATE_LENGTH = "The governorate code is one or two digits."
        const val REASON_GOVERNORATE_RANGE = "The governorate code is 1 to 22."
        const val REASON_SERIAL_NOT_NUMERIC = "The serial is digits only."
        const val REASON_SERIAL_LENGTH = "The serial is four to six digits."
        const val REASON_SERIAL_LEADING_ZERO = "The serial is not padded with leading zeros."
        const val MIN_SERIAL_LENGTH = 4
        const val MAX_SERIAL_LENGTH = 6

        /** `'05'` and `'5'` are the same governorate (two-cell padding). */
        fun validateFields(governorate: String, serial: String): PlateValidation {
            if (governorate.isEmpty() || governorate.length > 2) {
                return PlateValidation.invalid(REASON_GOVERNORATE_LENGTH)
            }
            if (!isDigits(governorate)) return PlateValidation.invalid(REASON_GOVERNORATE_NOT_NUMERIC)
            val code = governorate.toInt()
            if (code < MIN_GOVERNORATE || code > MAX_GOVERNORATE) {
                return PlateValidation.invalid(REASON_GOVERNORATE_RANGE)
            }
            if (serial.length < MIN_SERIAL_LENGTH || serial.length > MAX_SERIAL_LENGTH) {
                return PlateValidation.invalid(REASON_SERIAL_LENGTH)
            }
            if (!isDigits(serial)) return PlateValidation.invalid(REASON_SERIAL_NOT_NUMERIC)
            if (serial.startsWith("0")) return PlateValidation.invalid(REASON_SERIAL_LEADING_ZERO)
            return PlateValidation.valid
        }
    }
}

/** Judges a southern plate's number, gated on the serial: three to five digits. */
class YemenSouthernValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation = validateFields(entry.group("serial"))

    companion object {
        const val REASON_SERIAL_NOT_NUMERIC = "The number is digits only."
        const val REASON_SERIAL_LENGTH = "The number is three to five digits."
        const val MIN_SERIAL_LENGTH = 3
        const val MAX_SERIAL_LENGTH = 5

        fun validateFields(serial: String): PlateValidation {
            if (serial.length < MIN_SERIAL_LENGTH || serial.length > MAX_SERIAL_LENGTH) {
                return PlateValidation.invalid(REASON_SERIAL_LENGTH)
            }
            if (!isDigits(serial)) return PlateValidation.invalid(REASON_SERIAL_NOT_NUMERIC)
            return PlateValidation.valid
        }
    }
}

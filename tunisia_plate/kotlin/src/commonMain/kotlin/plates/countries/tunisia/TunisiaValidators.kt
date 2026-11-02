package plates.countries.tunisia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

/** An ordinary registration on `standard` or `square`: a series of up to three digits with no leading zero, then a registration of 0001-9999. Reports, never bars a keystroke. */
class TunisiaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry) = validateFields(series = entry.group("series"), number = entry.group("number"))

    companion object {
        const val REASON_SERIES = "The series is 1 to 999."
        const val REASON_NUMBER = "The registration is four digits."
        const val REASON_ZERO = "The registration is 0001 to 9999."

        fun validateFields(series: String, number: String): PlateValidation {
            if (series.isEmpty() || series.length > 3 || !isDigits(series) || series.startsWith("0")) {
                return PlateValidation.invalid(REASON_SERIES)
            }
            if (!isDigitsOfLength(number, 4)) return PlateValidation.invalid(REASON_NUMBER)
            if (number == "0000") return PlateValidation.invalid(REASON_ZERO)
            return PlateValidation.valid
        }
    }
}

/** A two-digit ministry code and the vehicle's number. */
class TunisiaGovernmentValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("ministry"), 2)) return PlateValidation.invalid(REASON_MINISTRY)
        val number = entry.group("number")
        if (!isDigits(number) || number.length > 6) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_MINISTRY = "The ministry code is two digits."
        const val REASON_NUMBER = "The vehicle number is one to six digits."
    }
}

/** Two two-digit numbers. An ambassador's `CMD` plate always ends `01`; pass [chief] for that spec. */
class TunisiaDiplomaticValidator(val chief: Boolean = false) : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val serial = entry.group("serial")
        if (!isDigitsOfLength(entry.group("country"), 2) || !isDigitsOfLength(serial, 2)) {
            return PlateValidation.invalid(REASON_DIGITS)
        }
        if (chief && serial != "01") return PlateValidation.invalid(REASON_CHIEF)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_DIGITS = "Both numbers are two digits."
        const val REASON_CHIEF = "A head of mission's plate ends 01."
    }
}

/** The five-digit serial of a military or temporary plate. */
class TunisiaSerialValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) =
        if (isDigitsOfLength(entry.group("serial"), 5)) PlateValidation.valid else PlateValidation.invalid(REASON_SERIAL)

    companion object {
        const val REASON_SERIAL = "The serial is five digits."
    }
}

package plates.countries.china

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

private const val SERIAL_CHARS = "0123456789ABCDEFGHJKLMNPQRSTUVWXYZ"
private const val CITY_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ"
private const val SUFFIXES = "学警挂港澳试超"
private const val ENERGY_LETTERS = "ABCDEFGHJK"

private fun isSerialChars(s: String) = s.isNotEmpty() && s.all { it in SERIAL_CHARS }

private fun letterCount(s: String) = s.count { it in CITY_CHARS }

/** Judges a `ChinaPlates.standard` value: a city letter (A-Z without I, O) and a five-character serial with at most two letters, whose last place may be a suffix Hanzi. Reports, never bars a keystroke. */
class ChinaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) = validateFields(entry.group("city"), entry.group("serial"))

    companion object {
        const val REASON_CITY = "The city letter is A–Z without I and O."
        const val REASON_SERIAL = "The serial is five digits or letters (no I, O), at most two of them letters; the last place may be 学 警 挂 港 澳 试 超."

        fun validateFields(city: String, serial: String): PlateValidation {
            if (city.length != 1 || city !in CITY_CHARS) return PlateValidation.invalid(REASON_CITY)
            if (serial.length != 5) return PlateValidation.invalid(REASON_SERIAL)
            val body = if (serial[4] in SUFFIXES) serial.substring(0, 4) else serial
            if (!isSerialChars(body) || letterCount(body) > 2) return PlateValidation.invalid(REASON_SERIAL)
            return PlateValidation.valid
        }
    }
}

/** `newEnergyLarge`: six serial characters, the energy letter first on a small plate and last on a large one. */
class ChinaNewEnergyValidator(val large: Boolean = false) : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val serial = entry.group("serial")
        if (serial.length != 6 || !isSerialChars(serial)) return PlateValidation.invalid(REASON_SERIAL)
        val energy = if (large) serial[5] else serial[0]
        if (energy !in ENERGY_LETTERS) return PlateValidation.invalid(REASON_ENERGY)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_SERIAL = "The serial is six digits or letters (no I, O)."
        const val REASON_ENERGY = "The energy letter is A–E or F–K (D electric, F other fuels)."
    }
}

/** Judges a `ChinaPlates.diplomatic` value: three digits of mission and three of serial. */
class ChinaDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("mission"), 3) || !isDigitsOfLength(entry.group("serial"), 3)) {
            return PlateValidation.invalid(REASON_DIGITS)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_DIGITS = "A diplomatic plate is a three-digit mission code and a three-digit serial."
    }
}

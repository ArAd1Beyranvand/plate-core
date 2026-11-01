package plates.countries.vanuatu

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

private val code = Regex("^[A-Z]{4}$")

/** Judges a `VanuatuPlates.standard` number: one to five digits. Reports, never bars. */
class VanuatuValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val number = entry.group("number")
        if (number.isEmpty() || number.length > 5 || !isDigits(number)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is 1 to 5 digits."
    }
}

/** Judges a `VanuatuPlates.diplomatic` value: four letters and one digit (`ABCD 1`). */
class VanuatuDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!code.matches(entry.group("code"))) return PlateValidation.invalid(REASON_CODE)
        val serial = entry.group("serial")
        if (serial.length != 1 || !isDigits(serial)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_CODE = "The code is four letters."
        const val REASON_SERIAL = "The serial is one digit."
    }
}

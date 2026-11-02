package plates.countries.sudan

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// SudanAlphabets.stateLatin.characters
private val stateLatin = listOf("KH", "G", "RS")

/** Judges a SudanPlates value: a class digit, a state code and a serial of four or five digits. Reports, never bars a keystroke. */
class SudanValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) =
        validateFields(entry.group("class"), entry.group("state"), entry.group("serial"))

    companion object {
        const val REASON_CLASS = "The class is one digit."
        const val REASON_STATE = "Unknown state code."
        const val REASON_SERIAL = "The serial is four or five digits."

        fun validateFields(classDigit: String, state: String, serial: String): PlateValidation {
            if (!isDigitsOfLength(classDigit, 1)) return PlateValidation.invalid(REASON_CLASS)
            if (state !in stateLatin) return PlateValidation.invalid(REASON_STATE)
            if (!isDigitsOfLength(serial, 4) && !isDigitsOfLength(serial, 5)) return PlateValidation.invalid(REASON_SERIAL)
            return PlateValidation.valid
        }
    }
}

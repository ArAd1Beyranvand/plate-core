package plates.countries.zimbabwe

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Judges a 2006 plate: three letters and four digits (`ABC 1234`). Reports,
 * never bars a keystroke. */
class ZimbabweValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val letters = entry.group("letters")
        if (letters == null || letters.length != 3 || !Regex("^[A-Z]{3}$").containsMatchIn(letters)) {
            return PlateValidation.invalid(REASON_LETTERS)
        }
        val serial = entry.group("serial")
        if (serial == null || !isDigitsOfLength(serial, 4)) {
            return PlateValidation.invalid(REASON_SERIAL)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The register is three letters."
        const val REASON_SERIAL = "The number is four digits."
    }
}

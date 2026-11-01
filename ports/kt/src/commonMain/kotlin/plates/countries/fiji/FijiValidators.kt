package plates.countries.fiji

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

private val letters = Regex("^[A-Z]{1,2}$")

/** Judges a Fijian plate: letters then digits (`AA 001`) or, for a motorcycle, digits then a letter. Reports, never bars a keystroke. */
class FijiValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        val serial = entry.group("serial")
        if (!isDigits(serial) || serial.length < 3 || serial.length > 4) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The register is one or two letters."
        const val REASON_SERIAL = "The number is three or four digits."
    }
}

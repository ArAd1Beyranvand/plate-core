package plates.countries.malawi

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isLetters

// H9: explicit ASCII class, portable across regex engines.

/** Judges a Malawian plate: two letters and four digits (`BC 5049`). Reports, never bars a keystroke. */
class MalawiValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isLetters(entry.group("letters"), 2)) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(entry.group("serial"), 4)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The register is two letters."
        const val REASON_SERIAL = "The number is four digits."
    }
}

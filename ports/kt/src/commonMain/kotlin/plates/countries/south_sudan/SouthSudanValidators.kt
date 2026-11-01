package plates.countries.south_sudan

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

private val letters = Regex("^[A-Z]{1,2}$")

/** Judges a 2017 plate: three digits, then one or two letters (`560 AT`). Reports, never bars a keystroke. */
class SouthSudanValidator : GatedPlateValidator() {
    override val gateGroup = "letters"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("serial"), 3)) return PlateValidation.invalid(REASON_SERIAL)
        if (!letters.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_SERIAL = "The number is three digits."
        const val REASON_LETTERS = "The register is one or two letters."
    }
}

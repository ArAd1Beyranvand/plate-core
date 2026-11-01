package plates.countries.malawi

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII class, portable across regex engines.
private val letters2 = Regex("^[A-Z]{2}$")

/** Judges a Malawian plate: two letters and four digits (`BC 5049`). Reports, never bars a keystroke. */
class MalawiValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters2.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(entry.group("serial"), 4)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The register is two letters."
        const val REASON_SERIAL = "The number is four digits."
    }
}

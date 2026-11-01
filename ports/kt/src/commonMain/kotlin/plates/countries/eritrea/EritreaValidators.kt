package plates.countries.eritrea

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Judges `ER`, a digit in the disc and a five-digit number (`ER – 3  01860`). Reports, never bars a keystroke. */
class EritreaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("code"), 1)) return PlateValidation.invalid(REASON_CODE)
        if (!isDigitsOfLength(entry.group("number"), 5)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_CODE = "The disc holds one digit."
        const val REASON_NUMBER = "The number is five digits."
    }
}

package plates.countries.polynesia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Judges a plate: four digits (`1234`). Reports, never bars a keystroke. */
class NiueValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) =
        if (isDigitsOfLength(entry.group("serial"), 4)) PlateValidation.valid else PlateValidation.invalid(REASON_SERIAL)

    companion object {
        const val REASON_SERIAL = "The number is four digits."
    }
}

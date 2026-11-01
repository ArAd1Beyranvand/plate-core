package plates.countries.dominica

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Requires exactly three digits. Reports, never bars a keystroke. */
class DominicaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) =
        if (isDigitsOfLength(entry.group("serial"), 3)) PlateValidation.valid else PlateValidation.invalid(REASON_SERIAL)

    companion object {
        const val REASON_SERIAL = "The number is three digits."
    }
}

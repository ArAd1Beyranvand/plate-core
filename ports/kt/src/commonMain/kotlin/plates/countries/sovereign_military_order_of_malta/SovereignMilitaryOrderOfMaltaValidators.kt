package plates.countries.sovereign_military_order_of_malta

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Judges an Order of Malta plate: the prefix `SMOM` and a two-digit number. Reports, never bars a keystroke. */
class SovereignMilitaryOrderOfMaltaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("prefix") != "SMOM") return PlateValidation.invalid(REASON_PREFIX)
        if (!isDigitsOfLength(entry.group("number"), 2)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is SMOM."
        const val REASON_NUMBER = "The number is two digits."
    }
}

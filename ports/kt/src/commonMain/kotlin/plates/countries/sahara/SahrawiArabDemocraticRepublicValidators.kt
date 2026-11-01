package plates.countries.sahara

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Judges a plate: `SH` or `GSH`, two digits and five digits, or nine digits on the army plate. */
class SahrawiArabDemocraticRepublicValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val serial = entry.group("serial")
        if (entry.spec.indicesOfGroup("prefix").isEmpty()) {
            return if (isDigitsOfLength(serial, 9)) PlateValidation.valid else PlateValidation.invalid(REASON_ARMY)
        }
        val prefix = entry.group("prefix")
        return if ((prefix == "SH" || prefix == "GSH") && isDigitsOfLength(entry.group("code"), 2) && isDigitsOfLength(serial, 5)) {
            PlateValidation.valid
        } else {
            PlateValidation.invalid(REASON_CIVIL)
        }
    }

    companion object {
        const val REASON_CIVIL = "A plate is SH or GSH, two digits and five digits."
        const val REASON_ARMY = "An army plate is nine digits."
    }
}

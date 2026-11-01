package plates.countries.maldives

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

/** Advisory validator for any `MaldivesPlates` value: one of the eight published category codes and a 1-4 digit serial. */
class MaldivesPlateValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("category") !in categories) return PlateValidation.invalid(REASON_CATEGORY)
        val s = entry.group("serial")
        if (!isDigits(s) || s.length > 4) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_CATEGORY = "Not a vehicle category code in the published table."
        const val REASON_SERIAL = "The serial is 1–4 digits."

        /** Motorcycles, passenger and goods. */
        val categories = setOf("A0", "A1", "B0", "B1", "B2", "C0", "C1", "C2")
    }
}

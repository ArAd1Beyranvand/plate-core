package plates.countries.kanak

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

/** Six digits, the printed `NC` being fixed. */
class NewCaledoniaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val v = entry.group("number")
        if (!entry.spec.slots.first().accepts(v) || v.length != 6) return PlateValidation.invalid(REASON_DIGITS)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_DIGITS = "The number must be six digits."
    }
}

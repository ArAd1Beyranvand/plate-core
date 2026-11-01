package plates.countries.russia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

/** Judges a South Ossetian registration: each field the right length and alphabet. Reports, never bars a keystroke. */
class SouthOssetiaValidator : GatedPlateValidator() {
    override val gateGroup = "series"

    override fun judge(entry: PlateEntry): PlateValidation {
        val spec = entry.spec
        for (i in spec.slots.indices) {
            val slot = spec.slots[i]
            val value = entry.group(spec.textGroups[i].key!!)
            if (!slot.accepts(value) || value.length < slot.minLength || value.length > slot.length) {
                return PlateValidation.invalid(REASON_FIELD)
            }
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_FIELD = "A field has the wrong length or letters."
    }
}

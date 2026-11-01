package plates.countries.argentina

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

/** Every field must use its alphabet and fit its slot. */
class FalklandIslandsValidator : GatedPlateValidator() {
    override val gateGroup = "digits"

    override fun judge(entry: PlateEntry): PlateValidation {
        val spec = entry.spec
        for ((i, slot) in spec.slots.withIndex()) {
            val v = entry.group(spec.textGroups[i].key!!)
            if (!slot.accepts(v) || v.length < slot.minLength || v.length > slot.length) {
                return PlateValidation.invalid(REASON_FIELD)
            }
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_FIELD = "A field has the wrong length or characters."
    }
}

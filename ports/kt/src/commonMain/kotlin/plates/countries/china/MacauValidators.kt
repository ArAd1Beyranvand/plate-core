package plates.countries.china

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

/** Every field must use its alphabet and fit its slot's length range. */
abstract class SlotsValidator : GatedPlateValidator() {
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

/** MA-12-34: a series of letters then two pairs of digits. */
class MacauValidator : SlotsValidator()

/** CM-x dddd: two to five digits. */
class MacauMopedValidator : SlotsValidator()

/** The Guangdong supplement: four characters, letters without I and O. */
class MacauMainlandValidator : SlotsValidator()

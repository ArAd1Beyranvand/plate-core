package plates.countries.haiti

import plates.core.alphabet.splitRunes
import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

/** Judges a Haitian registration field by field against the lengths the spec's slots give. Reports, never bars a keystroke. */
class HaitiValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        for (g in entry.spec.textGroups) {
            val key = g.key!!
            val slot = entry.spec.slots[entry.spec.indicesOfGroup(key).single()]
            val value = entry.group(key)
            val kind = if (key == "series") "letters" else "digits"
            val fits = value.length >= slot.minLength && value.length <= slot.length &&
                splitRunes(value).all(slot.alphabet::accepts)
            if (!fits) {
                return PlateValidation.invalid(
                    if (slot.minLength == slot.length) "The $key is ${slot.length} $kind."
                    else "The $key is ${slot.minLength} to ${slot.length} $kind.",
                )
            }
        }
        return PlateValidation.valid
    }
}

package plates.countries.saint_helena

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.restrictionVerdict

/** Quiet until something is typed, then every field must reach its minimum length (the `SHG` prefix whole, the serial one digit). */
class SaintHelenaValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        if (entry.values.all { it.isNullOrEmpty() }) return PlateValidation.valid
        for (g in entry.spec.effectiveTextGroups) {
            for (i in g.indices) {
                val slot = entry.spec.slotAt(i)
                val value = if (i < entry.values.size) entry.values[i] ?: "" else ""
                if (slot != null && !slot.isComplete(value)) {
                    return PlateValidation.invalid("The ${g.key ?: "field"} is incomplete.")
                }
            }
        }
        return PlateValidation.valid
    }
}

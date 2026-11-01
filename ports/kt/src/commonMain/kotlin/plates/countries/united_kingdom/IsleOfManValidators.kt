package plates.countries.united_kingdom

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.restrictionVerdict

/**
 * Quiet until something is typed, then every field must reach its minimum and
 * obey the Manx rules: the first letter is never `A`, the middle two are
 * `MN`, the serial is one to three digits and the last letter is never `O`.
 * `I`, `Q`, `S` and `Z` are excluded by the alphabets.
 */
class IsleOfManValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        if (entry.values.all { it.isNullOrEmpty() }) return PlateValidation.valid
        for (g in entry.spec.effectiveTextGroups) {
            for (i in g.indices) {
                val slot = entry.spec.slotAt(i)
                val value = if (i < entry.values.size) (entry.values[i] ?: "") else ""
                if (slot != null && !slot.isComplete(value)) {
                    return PlateValidation.invalid("The ${g.key ?: "field"} is incomplete.")
                }
                if (g.key == "prefix") {
                    if (value.startsWith("A")) return PlateValidation.invalid("The first letter is never A.")
                    if (value.substring(1) != "MN") return PlateValidation.invalid("The prefix is a letter followed by MN.")
                }
            }
        }
        return PlateValidation.valid
    }
}

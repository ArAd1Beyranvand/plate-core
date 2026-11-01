package plates.countries.united_kingdom

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.restrictionVerdict

private val forbidden = mapOf("area" to "IQZ", "random" to "IQ")

/**
 * Quiet until something is typed, then every field must reach its minimum
 * length and obey the DVLA letter rules: `area` never uses `I`, `Q` or `Z`
 * (`Z` is only a random letter), `random` never `I` or `Q`.
 */
class UnitedKingdomValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        if (entry.values.all { it.isNullOrEmpty() }) return PlateValidation.valid
        for (g in entry.spec.effectiveTextGroups) {
            val key = g.key
            for (i in g.indices) {
                val slot = entry.spec.slotAt(i)
                val value = if (i < entry.values.size) (entry.values[i] ?: "") else ""
                if (slot != null && !slot.isComplete(value)) {
                    return PlateValidation.invalid("The ${key ?: "field"} is incomplete.")
                }
                val bad = forbidden[key] ?: ""
                if (bad.isNotEmpty() && value.any { it in bad }) {
                    return PlateValidation.invalid("The $key never uses ${bad.toList().joinToString(", ")}.")
                }
            }
        }
        return PlateValidation.valid
    }
}

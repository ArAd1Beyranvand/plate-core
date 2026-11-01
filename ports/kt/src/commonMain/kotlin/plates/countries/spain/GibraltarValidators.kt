package plates.countries.spain

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.restrictionVerdict

/** Quiet until something is typed, then every field must reach its minimum length. The `prefix` is `G`, or `GT` on a trailer plate. */
class GibraltarValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        if (entry.values.all { it.isNullOrEmpty() }) return PlateValidation.valid
        for (g in entry.spec.effectiveTextGroups) {
            for (i in g.indices) {
                val slot = entry.spec.slotAt(i)
                val value = entry.values.getOrNull(i) ?: ""
                if (slot != null && !slot.isComplete(value)) {
                    return PlateValidation.invalid("The ${g.key ?: "field"} is incomplete.")
                }
                if (g.key == "prefix" && value != "G" && value != "GT") {
                    return PlateValidation.invalid("The prefix is G or GT.")
                }
                if (g.key == "serial" && entry.spec.id == "gi.private" && value.length == 4 && value.startsWith("0")) {
                    return PlateValidation.invalid("A four-digit serial runs 1000 to 9999.")
                }
            }
        }
        return PlateValidation.valid
    }
}

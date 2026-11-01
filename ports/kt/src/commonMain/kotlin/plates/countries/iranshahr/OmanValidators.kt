package plates.countries.iranshahr

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.restrictionVerdict

/** Every field at least at its minimum length. The article gives no rule beyond the format, so nothing else is judged. */
class OmanPlateValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        for (g in entry.spec.textGroups) {
            val key = g.key ?: continue
            for (i in g.indices) {
                if (!entry.spec.slots[i].isComplete(entry.values[i])) return PlateValidation.invalid("The $key is incomplete.")
            }
        }
        return PlateValidation.valid
    }
}

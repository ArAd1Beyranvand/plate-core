package plates.countries.united_kingdom

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.restrictionVerdict

/** Quiet until something is typed, then: The serial must hold one to six digits after the printed `J`. */
class JerseyValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val serial = entry.values.firstOrNull() ?: ""
        if (serial.isEmpty()) return PlateValidation.valid
        val slot = entry.spec.slotAt(0)
        if (slot != null && !slot.isComplete(serial)) return PlateValidation.invalid("The serial is incomplete.")
        return PlateValidation.valid
    }
}

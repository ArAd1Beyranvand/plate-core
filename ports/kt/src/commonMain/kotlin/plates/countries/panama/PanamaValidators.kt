package plates.countries.panama

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Judges a plate: six digits on a car (`686120`), `M` and five digits on a
 * motorcycle (`M 42421`). Reports, never bars a keystroke.
 *
 * The 2013 `AB1234` format and its class letters (T, B, G, D, CD, ...) are
 * not modelled: no reference of it was measured. */
class PanamaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val serial = entry.group("serial")
        val prefix = entry.group("class")
        if (prefix.isNotEmpty() && prefix != "M") {
            return PlateValidation.invalid(REASON_CLASS)
        }
        val length = if (prefix.isEmpty()) 6 else 5
        if (!isDigitsOfLength(serial, length)) {
            return PlateValidation.invalid(REASON_SERIAL)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_CLASS = "A motorcycle plate starts with M."
        const val REASON_SERIAL = "The number is six digits, five on a motorcycle."
    }
}

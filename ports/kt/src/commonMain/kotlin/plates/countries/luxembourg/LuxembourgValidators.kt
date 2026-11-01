package plates.countries.luxembourg

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.isDigits
import plates.core.validators.restrictionVerdict

/** One field's rule: letters or digits, [min] to [max] of them. */
private class Rule(val key: String, val digits: Boolean, val min: Int, val max: Int = min)

private val rules = mapOf(
    "lu.standard" to listOf(Rule("letters", false, 2), Rule("serial", true, 4)),
    "lu.diplomatic" to listOf(Rule("series", true, 2), Rule("serial", true, 2)),
    "lu.military" to listOf(Rule("serial", true, 4)),
)

/** Judges a Luxembourg plate field by field. Reports, never bars a keystroke. */
class LuxembourgValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val fields = rules[entry.spec.id] ?: emptyList()
        if (fields.all { entry.group(it.key).isEmpty() }) return PlateValidation.valid
        for (r in fields) {
            val v = entry.group(r.key)
            if (v.length < r.min || v.length > r.max) return PlateValidation.invalid(REASON_LENGTH)
            val hasDigit = v.any { it in '0'..'9' }
            if (if (r.digits) !isDigits(v) else hasDigit) return PlateValidation.invalid(REASON_KIND)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LENGTH = "A field has the wrong number of symbols."
        const val REASON_KIND = "A field mixes letters and digits."
    }
}

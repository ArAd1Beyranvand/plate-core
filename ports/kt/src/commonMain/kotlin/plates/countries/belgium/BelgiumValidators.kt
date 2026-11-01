package plates.countries.belgium

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.isDigits
import plates.core.validators.restrictionVerdict

/** One field's rule: letters or digits, between [min] and [max] of them. */
private class Rule(val key: String, val digits: Boolean, val min: Int, val max: Int = min)

/** Judges a Belgian plate field by field. Reports, never bars a keystroke.
 *
 * A plate is judged once any field holds a character; every field must then
 * be of its kind and within its length. Standard plates are `1-ABC-123`;
 * dealers' start with Z and a second letter A to Y (ZZ is reserved). */
class BelgiumValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val rules = rulesById[entry.spec.id] ?: emptyList()
        if (rules.all { entry.group(it.key).isEmpty() }) return PlateValidation.valid
        for (r in rules) {
            val v = entry.group(r.key)
            if (v.length < r.min || v.length > r.max) return PlateValidation.invalid(REASON_LENGTH)
            val noDigits = v.none { it in '0'..'9' }
            if (if (r.digits) !isDigits(v) else !noDigits) return PlateValidation.invalid(REASON_KIND)
        }
        if (entry.spec.id == "be.plain" && entry.group("letters").startsWith("ZZ")) {
            return PlateValidation.invalid(REASON_DEALER)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LENGTH = "A field has the wrong number of symbols."
        const val REASON_KIND = "A field mixes letters and digits."
        const val REASON_DEALER = "A dealer plate (first letter Z) has a second letter from A to Y."

        private val threeFields = listOf(Rule("series", true, 1), Rule("letters", false, 3), Rule("serial", true, 3))

        private val rulesById = mapOf(
            "be.private" to threeFields,
            "be.plain" to threeFields,
            "be.motorcycle" to listOf(Rule("series", false, 1), Rule("letters", false, 3), Rule("serial", true, 3)),
            "be.temporary" to listOf(Rule("kind", false, 2), Rule("number", true, 2), Rule("letters", false, 3)),
            "be.vintage" to listOf(Rule("series", true, 3), Rule("serial", true, 3)),
            "be.diplomatic" to listOf(Rule("letters", false, 2), Rule("serial", true, 3)),
            "be.royal" to listOf(Rule("number", true, 1, 2)),
            "be.military" to listOf(Rule("serial", true, 5)),
        )
    }
}

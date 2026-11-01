package plates.countries.austria

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.restrictionVerdict

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters12 = Regex("^[A-Z]{1,2}$")
private val digits15 = Regex("^[0-9]{1,5}$")

private val district = linkedMapOf("a" to letters12, "b" to digits15, "c" to letters12)

/** Spec id -> one pattern per field key, in field order. */
private val formats = mapOf(
    "at.private" to district,
    "at.electric" to district,
    "at.trailer" to district,
    "at.export" to linkedMapOf("a" to letters12, "b" to Regex("^[0-9]{1,3}$"), "c" to letters12),
    "at.temporary" to linkedMapOf(
        "a" to letters12, "b" to Regex("^[0-9]{1,2}$"), "c" to letters12, "d" to Regex("^[0-9]{2}$"),
    ),
    "at.fire" to linkedMapOf("a" to Regex("^FW$"), "b" to Regex("^[0-9]{1,4}$"), "c" to letters12),
    "at.federal" to linkedMapOf("a" to letters12, "b" to digits15),
    "at.diplomatic" to linkedMapOf("a" to Regex("^[A-Z]{2}$"), "mission" to Regex("^[0-9]{1,2}$")),
    "at.personalised" to linkedMapOf("a" to letters12, "b" to Regex("^[A-Z]{1,5}$"), "c" to Regex("^[0-9]{1,3}$")),
    "at.moped" to linkedMapOf("a" to letters12, "b" to Regex("^[0-9]{1,3}$"), "c" to Regex("^[A-Z]{1,3}$")),
)

/**
 * Judges an Austrian plate field by field, `a`, `b`, `c`.
 *
 * Ordinary plates are one or two district letters, one to five digits and one or two letters; federal plates letters and digits; diplomatic plates `WD` and a mission code (1-2 digits); personalised plates a block of letters then a block of digits, at least three characters together. Reports, never bars a keystroke; judged once the last register has content.
 */
class AustriaValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val format = formats[entry.spec.id]
        if (format == null || entry.group(format.keys.last()).isEmpty()) return PlateValidation.valid
        for ((key, pattern) in format) {
            if (!pattern.matches(entry.group(key))) return PlateValidation.invalid(REASON)
        }
        if (entry.spec.id == "at.personalised" && entry.group("b").length + entry.group("c").length < 3) {
            return PlateValidation.invalid(REASON)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON = "The plate does not match its format."
    }
}

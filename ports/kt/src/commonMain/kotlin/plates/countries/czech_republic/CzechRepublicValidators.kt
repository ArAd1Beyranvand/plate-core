package plates.countries.czech_republic

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val current = mapOf(
    "a" to Regex("^([0-9][ABCEHJKLMPSTUZ][A-Z0-9]|EL[0-9])$"),
    "b" to Regex("^[A-Z0-9]{4}$"),
)
private val digitPairs = mapOf("b" to Regex("^[0-9]{2}$"), "c" to Regex("^[0-9]{2}$"))

private fun fields(vararg f: Pair<String, String>) = f.associate { (k, v) -> k to Regex(v) }

private val formats: Map<String, Map<String, Regex>> = mapOf(
    "cz.private" to current,
    "cz.private2001" to current,
    "cz.usSize" to current,
    "cz.motorcycle" to fields("a" to "^[A-Z0-9]{2}$", "b" to "^[0-9]{4}$"),
    "cz.personalised" to fields("a" to "^[A-Z0-9]{1,3}$", "b" to "^[A-Z0-9]{1,5}$"),
    "cz.classic" to mapOf("a" to Regex("^[A-Z]{2,3}$")) + digitPairs,
    "cz.classic70s" to mapOf("a" to Regex("^[A-Z]{2}$")) + digitPairs,
    "cz.military" to mapOf("a" to Regex("^[0-9]{3}$")) + digitPairs,
    "cz.export" to fields("a" to "^[A-Z0-9]{3}$", "b" to "^[A-Z0-9]{3}$"),
    "cz.diplomatic" to fields("a" to "^[0-9]{3}$", "b" to "^[A-Z]{2}$", "c" to "^[0-9]{2}$"),
    "cz.veteran" to fields("a" to "^V$", "b" to "^[0-9]{4}$"),
)

/** Judges a Czech plate field by field, `a`, `b`, `c`. Reports, never bars a keystroke. */
class CzechRepublicValidator : GatedPlateValidator() {
    override val gateGroup = "b"

    override fun judge(entry: PlateEntry): PlateValidation {
        val format = formats[entry.spec.id] ?: return PlateValidation.valid
        for ((key, re) in format) if (!re.matches(entry.group(key))) return PlateValidation.invalid(REASON)
        return PlateValidation.valid
    }

    companion object {
        const val REASON = "The plate does not match its format."
    }
}

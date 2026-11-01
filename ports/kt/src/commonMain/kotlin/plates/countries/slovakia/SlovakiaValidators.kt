package plates.countries.slovakia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val twoLetters = Regex("^[A-Z]{2}$")
private val oneLetter = Regex("^[A-Z]$")
private val threeDigits = Regex("^[0-9]{3}$")
private val fiveDigits = Regex("^[0-9]{5}$")

private val lettersDigitsLetters = mapOf("a" to twoLetters, "b" to threeDigits, "c" to twoLetters)
private val twoLine = mapOf("a" to twoLetters, "b" to oneLetter, "c" to threeDigits)

/** Judges a Slovak plate field by field (`a`, `b`, `c`). Reports, never bars a keystroke. */
class SlovakiaValidator : GatedPlateValidator() {
    override val gateGroup = "b"

    override fun judge(entry: PlateEntry): PlateValidation {
        val format = formats[entry.spec.id] ?: return PlateValidation.valid
        for ((key, re) in format) if (!re.matches(entry.group(key))) return PlateValidation.invalid(REASON)
        return PlateValidation.valid
    }

    companion object {
        const val REASON = "The plate does not match its format."

        /** Spec id -> one pattern per field key. */
        private val formats = mapOf(
            "sk.private" to lettersDigitsLetters,
            "sk.privateDash" to lettersDigitsLetters,
            "sk.legacy" to lettersDigitsLetters,
            "sk.temporary" to twoLine,
            "sk.dealer" to twoLine,
            "sk.personalised" to mapOf("a" to twoLetters, "b" to Regex("^[A-Z0-9]{1,5}$")),
            "sk.imported" to mapOf("a" to oneLetter, "b" to fiveDigits),
            "sk.military" to mapOf("a" to Regex("^[0-9]{2}$"), "b" to fiveDigits),
            "sk.diplomatic" to mapOf("a" to twoLetters, "b" to fiveDigits),
            "sk.officials" to mapOf("a" to twoLetters, "b" to oneLetter, "c" to threeDigits),
        )
    }
}

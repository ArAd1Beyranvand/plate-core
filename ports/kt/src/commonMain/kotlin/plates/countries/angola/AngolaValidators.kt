package plates.countries.angola

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Judges AA-##-##-AA: a two-letter region code, two pairs of digits and two letters. Reports, never bars a keystroke. */
class AngolaValidator : GatedPlateValidator() {
    override val gateGroup = "suffix"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters(entry.group("region"))) return PlateValidation.invalid(REASON_REGION)
        if (!isDigitsOfLength(entry.group("first"), 2) || !isDigitsOfLength(entry.group("second"), 2)) {
            return PlateValidation.invalid(REASON_DIGITS)
        }
        if (!letters(entry.group("suffix"))) return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_REGION = "The region is two letters."
        const val REASON_DIGITS = "The number is two pairs of digits."
        const val REASON_SUFFIX = "The series is two letters."

        // H9: explicit ASCII class, portable across JVM/JS/Wasm regex engines.
        private val pair = Regex("^[A-Z]{2}$")

        private fun letters(s: String) = pair.matches(s)
    }
}

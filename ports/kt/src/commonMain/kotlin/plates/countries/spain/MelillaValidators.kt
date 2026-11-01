package plates.countries.spain

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isLetters

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val melillaConsonants = Regex("^[BCDFGHJKLMNPRSTVWXYZ]{3}$")
private val melillaDiplomaticCodes = listOf("CD", "CC", "TA", "OI")

/** Judges a Melilla plate. Reports, never bars a keystroke; the one refusal is the restriction the diplomatic specs carry. */
class MelillaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val code = entry.group("code")
        if (code.isNotEmpty()) {
            if (code !in melillaDiplomaticCodes) return PlateValidation.invalid(REASON_CODE)
            val embassy = entry.group("embassy")
            if (!isDigits(embassy) || embassy.length > 3) return PlateValidation.invalid(REASON_EMBASSY)
            if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_CAR)
            return PlateValidation.valid
        }
        if (!isDigitsOfLength(entry.group("number"), 4)) return PlateValidation.invalid(REASON_NUMBER)
        val prefix = entry.group("prefix")
        if (prefix.isNotEmpty()) {
            return if (isLetters(prefix, 1, 3)) PlateValidation.valid else PlateValidation.invalid(REASON_PREFIX)
        }
        if (!melillaConsonants.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is four digits."
        const val REASON_LETTERS = "The counter is three consonants (no vowels, no Q)."
        const val REASON_CODE = "The prefix is CD, CC, TA or OI."
        const val REASON_EMBASSY = "The embassy code is one to three digits."
        const val REASON_CAR = "The car number is three digits."
        const val REASON_PREFIX = "The prefix is one to three letters."
    }
}

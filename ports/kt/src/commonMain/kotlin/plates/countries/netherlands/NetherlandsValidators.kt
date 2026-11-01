package plates.countries.netherlands

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val alphanumeric = Regex("^[A-Z0-9]+$")
private val upper = Regex("^[A-Z]+$")
private const val CONSONANTS = "BDFGHJKLNPRSTVXZ"

/**
 * Judges a Dutch plate, field by field (groups `a`, `b`, `c`). Ordinary registrations use only the consonants; the special
 * series print other letters, so a letter outside the consonants is only reported in an otherwise ordinary run of three letters.
 */
class NetherlandsValidator : GatedPlateValidator() {
    override val gateGroup = "a"

    override fun judge(entry: PlateEntry): PlateValidation {
        for (key in listOf("a", "b", "c")) {
            val field = entry.group(key)
            if (field.isNotEmpty() && !alphanumeric.matches(field)) return PlateValidation.invalid(REASON_CHARACTERS)
            if (field.length == 3 && upper.matches(field) && field != "CDJ" && field != "BFG" &&
                !field.all { it in CONSONANTS }
            ) {
                return PlateValidation.invalid(REASON_LETTERS)
            }
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_CHARACTERS = "A field is letters A–Z or digits 0–9 only."
        const val REASON_LETTERS = "Ordinary plates use only the letters B D F G H J K L N P R S T V X Z."
    }
}

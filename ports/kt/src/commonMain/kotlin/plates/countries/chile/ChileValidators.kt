package plates.countries.chile

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val consonants = Regex("^[BCDFGHJKLPRSTVWXYZ]+$")
private val letters = Regex("^[A-Z]+$")
private val digits = Regex("^[0-9]+$")
private val diplomaticPrefixes = listOf("CD", "CC", "AT", "CH", "OI", "PAT")

/**
 * Judges a Chilean plate by which groups it has: `first`/`second`/`number` (four consonants and two digits, or a
 * trailer's two letters and two pairs of digits), `first`/`mission`/`number` (diplomatic), `first` of three letters
 * (light trailer), or `first`/`number` (provisional `PR` or police). Reports, never bars a keystroke.
 */
class ChileValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val first = entry.group("first")
        val second = entry.group("second")
        val mission = entry.group("mission")
        val number = entry.group("number")

        if (mission.isNotEmpty()) {
            if (first !in diplomaticPrefixes) return PlateValidation.invalid(REASON_DIPLOMATIC)
            if (!isDigitsOfLength(mission, 2) || !isDigitsOfLength(number, 2)) return PlateValidation.invalid(REASON_NUMBER)
            return PlateValidation.valid
        }
        if (second.isNotEmpty()) {
            if (digits.matches(second)) {
                if (!letters.matches(first) || !isDigitsOfLength(second, 2) || !isDigitsOfLength(number, 2)) {
                    return PlateValidation.invalid(REASON_TRAILER)
                }
                return PlateValidation.valid
            }
            if (!consonants.matches(first) || !consonants.matches(second)) return PlateValidation.invalid(REASON_LETTERS)
            if (!isDigitsOfLength(number, 2)) return PlateValidation.invalid(REASON_NUMBER)
            return PlateValidation.valid
        }
        if (first.length == 3) {
            if (!consonants.matches(first) || !isDigitsOfLength(number, 3)) return PlateValidation.invalid(REASON_LIGHT)
            return PlateValidation.valid
        }
        if (first == "PR") {
            if (!isDigitsOfLength(number, 3) && !isDigitsOfLength(number, 4)) return PlateValidation.invalid(REASON_PROVISIONAL)
            return PlateValidation.valid
        }
        if (!letters.matches(first) || !isDigitsOfLength(number, 4)) return PlateValidation.invalid(REASON_POLICE)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The letters are consonants (no M, N, Ñ or Q)."
        const val REASON_NUMBER = "The number is two digits."
        const val REASON_DIPLOMATIC = "A diplomatic plate starts CD, CC, AT, CH, OI or PAT."
        const val REASON_TRAILER = "A trailer plate is two letters and two pairs of digits."
        const val REASON_LIGHT = "A light trailer is three consonants and three digits."
        const val REASON_PROVISIONAL = "A provisional plate is PR and three or four digits."
        const val REASON_POLICE = "A police plate is letters and four digits."
    }
}

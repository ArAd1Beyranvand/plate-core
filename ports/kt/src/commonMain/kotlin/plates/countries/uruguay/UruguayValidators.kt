package plates.countries.uruguay

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters = Regex("^[A-S][A-Z]{2}$")
private val digits = Regex("^[0-9]{1,4}$")

/**
 * Judges a Uruguayan serial `A BC 1234`: three letters in `first`, the first
 * a department code (A to S), and one to four digits in `number`.
 * The category letters are not checked. Reports, never bars a keystroke.
 */
class UruguayValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters.matches(entry.group("first"))) return PlateValidation.invalid(REASON_LETTERS)
        if (!digits.matches(entry.group("number"))) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "A serial is three letters, the first a department code (A to S)."
        const val REASON_NUMBER = "The number is one to four digits."
    }
}

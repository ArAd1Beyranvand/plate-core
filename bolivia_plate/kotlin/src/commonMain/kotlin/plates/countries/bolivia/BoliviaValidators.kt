package plates.countries.bolivia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isLetters

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.

/** The department letter in the PTA plate's box (BoliviaAlphabets.departments). */
private val departments = "C H B L O N P S T".split(" ")

/** Judges a `BoliviaPlates.standard` value. Reports, never bars a keystroke.
 *
 * Checks what the article states: the PTA number is three or four digits
 * and three letters, and the box holds one of the nine department letters. */
class BoliviaValidator : GatedPlateValidator() {
    override val gateGroup = "letters"

    override fun judge(entry: PlateEntry) =
        validateFields(entry.group("number"), entry.group("letters"), entry.group("department"))

    companion object {
        const val REASON_NUMBER = "The number is three or four digits."
        const val REASON_LETTERS = "The series is three letters."
        const val REASON_DEPARTMENT = "The department is one of C H B L O N P S T."

        fun validateFields(number: String, letters: String, department: String): PlateValidation {
            if ((number.length != 3 && number.length != 4) || !isDigits(number)) return PlateValidation.invalid(REASON_NUMBER)
            if (!isLetters(letters, 3)) return PlateValidation.invalid(REASON_LETTERS)
            if (department !in departments) return PlateValidation.invalid(REASON_DEPARTMENT)
            return PlateValidation.valid
        }
    }
}

/** Judges a `BoliviaPlates.special` value: two two-digit numbers, the mission's country and the vehicle's rank. */
class BoliviaSpecialValidator : GatedPlateValidator() {
    override val gateGroup = "rank"

    override fun judge(entry: PlateEntry) =
        if (isDigitsOfLength(entry.group("country"), 2) && isDigitsOfLength(entry.group("rank"), 2)) PlateValidation.valid
        else PlateValidation.invalid(REASON_DIGITS)

    companion object {
        const val REASON_DIGITS = "Both numbers are two digits."
    }
}

/** Judges a `BoliviaPlates.mercosur` value: two letters and five digits. */
class BoliviaMercosurValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isLetters(entry.group("letters"), 2)) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(entry.group("number"), 5)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The series is two letters."
        const val REASON_NUMBER = "The number is five digits."
    }
}

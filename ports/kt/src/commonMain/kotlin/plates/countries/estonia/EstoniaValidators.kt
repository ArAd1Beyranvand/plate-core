package plates.countries.estonia

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength
import plates.core.validators.restrictionVerdict

/** Judges an Estonian plate, field by field: regular, diplomatic (`CD`/`AT`/`CMD`) and Defence Forces. Reports, never bars a keystroke. */
class EstoniaValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val number = entry.group("number")
        val letters = entry.group("letters")
        val code = entry.group("code")
        if (code.isNotEmpty()) return diplomatic(code, number)
        if (number.isEmpty() || letters.isEmpty()) return PlateValidation.valid
        if (entry.spec.id == "ee.defence") {
            val shape = letters.length == 2 && letters.startsWith("K") ||
                letters.length == 3 && letters.startsWith("EK")
            return if (isDigitsOfLength(number, 3) && shape) PlateValidation.valid
            else PlateValidation.invalid(REASON_DEFENCE)
        }
        return if (isDigitsOfLength(number, 3) && letters.length == 3) PlateValidation.valid
        else PlateValidation.invalid(REASON_REGULAR)
    }

    private fun diplomatic(code: String, number: String): PlateValidation {
        val min = when (code) {
            "CD", "AT" -> 3
            "CMD" -> 2
            else -> null
        }
        if (min == null) {
            return if (code.length < 2) PlateValidation.valid else PlateValidation.invalid(REASON_CODE)
        }
        if (number.isEmpty()) return PlateValidation.valid
        return if (isDigits(number) && number.length >= min && number.length <= min + 1) PlateValidation.valid
        else PlateValidation.invalid(REASON_DIPLOMATIC)
    }

    companion object {
        const val REASON_REGULAR = "Three digits then three letters."
        const val REASON_CODE = "The prefix is CD, AT or CMD."
        const val REASON_DIPLOMATIC = "CD and AT take three or four digits, CMD two or three."
        const val REASON_DEFENCE = "Three digits, then K and a letter or EK and a letter."
    }
}

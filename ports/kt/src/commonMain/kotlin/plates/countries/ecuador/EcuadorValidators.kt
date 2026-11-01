package plates.countries.ecuador

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.isLetters
import plates.core.validators.restrictionVerdict

private val number = Regex("^[0-9]{3,4}$")

/** Judges an Ecuadorian plate field by field. Quiet until the number has something in it. */
class EcuadorValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val letters = entry.group("letters")
        val digits = entry.group("number")
        if (digits.isEmpty()) return PlateValidation.valid
        if (entry.spec.id == "ec.protocol") {
            if (letters !in protocolCodes) return PlateValidation.invalid(REASON_CODE)
        } else if (!isLetters(letters, 3)) {
            return PlateValidation.invalid(REASON_LETTERS)
        } else if (letters.substring(0, 1) !in provinces) {
            return PlateValidation.invalid(REASON_PROVINCE)
        }
        if (!number.matches(digits)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        /** The first letter of a standard plate names the province of issue. */
        val provinces = "ABUCXHOEWGILRMVNSPQKTZYJ".map { it.toString() }.toSet()
        val protocolCodes = setOf("CC", "CD", "OI", "AT", "IT")

        const val REASON_PROVINCE = "The first letter names a province."
        const val REASON_LETTERS = "A plate starts with three letters."
        const val REASON_CODE = "The code is CC, CD, OI, AT or IT."
        const val REASON_NUMBER = "The number is 3 or 4 digits."
    }
}

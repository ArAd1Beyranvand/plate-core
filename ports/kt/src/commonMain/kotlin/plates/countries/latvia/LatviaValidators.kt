package plates.countries.latvia

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength
import plates.core.validators.restrictionVerdict

/** Judges a Latvian plate, field by field. Reports, never bars a keystroke. */
class LatviaValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val letters = entry.group("letters")
        val number = entry.group("number")
        if (letters.isEmpty() || number.isEmpty()) return PlateValidation.valid
        if (entry.spec.id == "lv.diplomatic") {
            return if ((letters == "CD" || letters == "C") && isDigitsOfLength(number, 4)) {
                PlateValidation.valid
            } else {
                PlateValidation.invalid(REASON_DIPLOMATIC)
            }
        }
        if (letters.length != 2 || !isDigits(number)) return PlateValidation.invalid(REASON_REGULAR)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_REGULAR = "Two letters, then one to four digits."
        const val REASON_DIPLOMATIC = "CD, then four digits."
    }
}

package plates.countries.paraguay

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

private val letters = Regex("^[A-Z]{4}$")
private val digits = Regex("^[0-9]{3}$")

/** Judges a Paraguayan Mercosur serial `AAAA 123`. Reports, never bars a keystroke. */
class ParaguayValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        if (!digits.matches(entry.group("number"))) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The series is four letters."
        const val REASON_NUMBER = "The number is three digits."
    }
}

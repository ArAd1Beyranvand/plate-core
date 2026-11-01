package plates.countries.saint_lucia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

// H9: explicit ASCII classes.
private val digits = Regex("^[0-9]{1,4}$")
private val letters = Regex("^[A-Z]{1,3}$")

/** Judges a plate: a one to three letter prefix and one to four digits. Reports, never bars a keystroke. */
class SaintLuciaValidator : GatedPlateValidator() {
    override val gateGroup = "digits"

    override fun judge(entry: PlateEntry) =
        if (digits.matches(entry.group("digits")) && letters.matches(entry.group("letters"))) {
            PlateValidation.valid
        } else {
            PlateValidation.invalid(REASON)
        }

    companion object {
        const val REASON = "A plate is a one to three letter prefix and one to four digits."
    }
}

package plates.countries.saint_kitts_and_nevis

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

// H9: explicit ASCII classes.
private val digits = Regex("^[0-9]{1,4}$")
private val letters = Regex("^[A-Z]{1,2}$")

/** Judges a plate: the `P` prefix, optionally with a second letter,  and one to four digits. Reports, never bars a keystroke. */
class SaintKittsAndNevisValidator : GatedPlateValidator() {
    override val gateGroup = "digits"

    override fun judge(entry: PlateEntry) =
        if (digits.matches(entry.group("digits")) && letters.matches(entry.group("letters"))) {
            PlateValidation.valid
        } else {
            PlateValidation.invalid(REASON)
        }

    companion object {
        const val REASON = "A plate is one or two letters and one to four digits."
    }
}

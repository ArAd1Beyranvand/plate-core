package plates.countries.barbados

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

/** Judges a Barbadian plate: one or two letters (the parish or category code)
 * and one to four digits (`L 4159`, `MA 999`). Reports, never bars a keystroke. */
class BarbadosValidator : GatedPlateValidator() {
    override val gateGroup = "digits"

    override fun judge(entry: PlateEntry) =
        if (entry.group("digits")?.matches(Regex("^[0-9]{1,4}$")) == true &&
            entry.group("letters")?.matches(Regex("^[A-Z]{1,2}$")) == true) PlateValidation.valid
        else PlateValidation.invalid(REASON)

    companion object {
        const val REASON = "A plate is one or two letters and one to four digits."
    }
}

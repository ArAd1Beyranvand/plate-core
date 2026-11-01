package plates.countries.saint_vincent_and_the_grenadines

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII class, portable across JVM/JS/Wasm regex engines.
private val letter = Regex("^[A-Z]$")

/** Judges a Vincentian plate: one letter and four digits (`A 1234`). Reports, never bars a keystroke. */
class SaintVincentAndTheGrenadinesValidator : GatedPlateValidator() {
    override val gateGroup = "digits"

    override fun judge(entry: PlateEntry): PlateValidation =
        if (isDigitsOfLength(entry.group("digits"), 4) && letter.matches(entry.group("letters"))) PlateValidation.valid
        else PlateValidation.invalid(REASON)

    companion object {
        const val REASON = "A plate is one letter and four digits."
    }
}

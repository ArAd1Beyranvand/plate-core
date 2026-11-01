package plates.countries.tuvalu

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters = Regex("^[A-Z]{2}$")

/** Judges a Tuvalu plate by its groups: `letters` (two) and `serial` (four digits), `AB 1234`. Reports, never bars a keystroke. */
class TuvaluValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("letters").isNotEmpty() && !letters.matches(entry.group("letters"))) {
            return PlateValidation.invalid(REASON_LETTERS)
        }
        if (!isDigitsOfLength(entry.group("serial"), 4)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The register is two letters."
        const val REASON_SERIAL = "The number is four digits."
    }
}

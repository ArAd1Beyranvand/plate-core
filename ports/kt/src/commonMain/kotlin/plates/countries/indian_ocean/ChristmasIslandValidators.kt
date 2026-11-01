package plates.countries.indian_ocean

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII class, portable across JVM/JS/Wasm regex engines.
private val letters2 = Regex("^[A-Z]{2}$")

/** Judges a `CI•1234` value: a two-letter register then a four-digit serial (leading zeros are printed). Reports, never bars a keystroke. */
class ChristmasIslandValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters2.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(entry.group("serial"), 4)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The register is two letters."
        const val REASON_SERIAL = "The number is four digits."
    }
}

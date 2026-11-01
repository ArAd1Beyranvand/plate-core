package plates.countries.indian_ocean

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Judges a plate by its groups: `letters` (one, `C`) and `serial` (three digits), `C 400`. Reports, never bars a keystroke. */
class CocosKeelingIslandsValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val letters = entry.group("letters")
        if (letters.isNotEmpty() && letters != "C") return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(entry.group("serial"), 3)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The register is the letter C."
        const val REASON_SERIAL = "The number is three digits."
    }
}

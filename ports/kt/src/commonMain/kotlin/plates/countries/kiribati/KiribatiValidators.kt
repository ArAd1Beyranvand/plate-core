package plates.countries.kiribati

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

private val lettersRe = Regex("^[A-Z]{3}$")

/** Judges a Kiribati plate by `letters` (three) and `serial` (three digits). Reports, never bars a keystroke. */
class KiribatiValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val letters = entry.group("letters")
        if (letters.isNotEmpty() && !lettersRe.matches(letters)) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(entry.group("serial"), 3)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The register is three letters."
        const val REASON_SERIAL = "The number is three digits."
    }
}

package plates.countries.polynesia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isLetters


/** Judges a plate: four digits (car) or three letters over three digits (motorcycle). */
class CookIslandsValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val letters = entry.group("letters")
        val serial = entry.group("serial")
        if (entry.spec.slots.size == 1) {
            return if (isDigitsOfLength(serial, 4)) PlateValidation.valid else PlateValidation.invalid(REASON_CAR)
        }
        if (!isLetters(letters, 3)) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(serial, 3)) return PlateValidation.invalid(REASON_MOTORCYCLE)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_CAR = "The number is four digits."
        const val REASON_LETTERS = "The register is three letters."
        const val REASON_MOTORCYCLE = "The number is three digits."
    }
}

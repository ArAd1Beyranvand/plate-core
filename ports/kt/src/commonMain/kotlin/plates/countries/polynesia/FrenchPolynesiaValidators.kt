package plates.countries.polynesia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

private val letterRe = Regex("^[A-HJ-NP-TV-Z]$")

/** Judges a French Polynesia plate: six digits and one letter (no I, O, U). */
class FrenchPolynesiaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("number"), 6)) return PlateValidation.invalid(REASON_NUMBER)
        if (!letterRe.matches(entry.group("letter"))) return PlateValidation.invalid(REASON_LETTER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is six digits."
        const val REASON_LETTER = "The letter is one of A–Z without I, O, U."
    }
}

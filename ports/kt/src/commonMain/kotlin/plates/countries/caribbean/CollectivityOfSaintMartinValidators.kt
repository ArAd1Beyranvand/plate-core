package plates.countries.caribbean

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

private val numberRe = Regex("^[0-9]{3,4}$")
private val lettersRe = Regex("^[A-HJ-NP-TV-Z]{2,3}$")

/** Judges a Saint Martin plate: three or four digits, then two or three letters (no I, O, U or SS). */
class CollectivityOfSaintMartinValidator : GatedPlateValidator() {
    override val gateGroup = "letters"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!numberRe.matches(entry.group("number"))) return PlateValidation.invalid(REASON_NUMBER)
        val letters = entry.group("letters")
        if (!lettersRe.matches(letters) || "SS" in letters) return PlateValidation.invalid(REASON_LETTERS)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is three or four digits."
        const val REASON_LETTERS = "The letters are two or three (no I, O, U or SS)."
    }
}

package plates.countries.djibouti

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Judges a Djibouti registration: three digits, the letter `D`, two digits (`683 D 30`). */
class DjiboutiValidator : GatedPlateValidator() {
    override val gateGroup = "code"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_NUMBER)
        if (entry.group("letter") != "D") return PlateValidation.invalid(REASON_LETTER)
        if (!isDigitsOfLength(entry.group("code"), 2)) return PlateValidation.invalid(REASON_CODE)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is three digits."
        const val REASON_LETTER = "The letter is D."
        const val REASON_CODE = "The code is two digits."
    }
}

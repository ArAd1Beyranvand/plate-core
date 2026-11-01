package plates.countries.caribbean

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

/** Judges a St. Eustatius value: the island letter `E` and one to four digits. */
class SintEustatiusValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("prefix") != "E") return PlateValidation.invalid(REASON_PREFIX)
        val number = entry.group("number")
        if (number.isEmpty() || number.length > 4 || !isDigits(number)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is E."
        const val REASON_NUMBER = "The number is up to four digits."
    }
}

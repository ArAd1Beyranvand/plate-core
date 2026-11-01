package plates.countries.caribbean

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isLetters

private val serialRe = Regex("^[0-9]{1,4}$")

/** Judges a Montserrat plate: a type letter and one to four digits (`M 1667`). */
class MontserratValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isLetters(entry.group("type"), 1)) return PlateValidation.invalid(REASON_TYPE)
        if (!serialRe.matches(entry.group("serial"))) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_TYPE = "The type is one letter."
        const val REASON_SERIAL = "The number is one to four digits."
    }
}

package plates.countries.yemen

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

/** Judges a Riyadh plate: three letters from the seventeen issued and one to four digits. */
class RiyadhValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!lettersRe.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        val serial = entry.group("serial")
        if (!isDigits(serial) || serial.length > 4) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The register is three letters."
        const val REASON_SERIAL = "The number is one to four digits."

        private val lettersRe = Regex("^[ABJDRSXTEGKLZNHUV]{3}$")
    }
}

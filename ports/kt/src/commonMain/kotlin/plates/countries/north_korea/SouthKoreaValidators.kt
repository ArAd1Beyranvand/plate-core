package plates.countries.north_korea

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

/** Judges the class digits (two or three on a passenger plate since 2019, one to two on others), the Hangul syllable and the serial. */
class SouthKoreaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val id = entry.spec.id
        val cls = entry.group("class")
        val serial = entry.group("serial")
        val letter = entry.group("letter")

        if (id == "kr.diplomatic") {
            return if (isDigitsOfLength(cls, 3) && isDigitsOfLength(serial, 3)) PlateValidation.valid
            else PlateValidation.invalid(REASON_DIPLOMATIC)
        }
        if (id == "kr.us_forces") {
            return if (isDigitsOfLength(cls, 1) && isDigitsOfLength(serial, 4)) PlateValidation.valid
            else PlateValidation.invalid(REASON_US_FORCES)
        }

        val commercial = id == "kr.commercial"
        if (letter.isEmpty() || !isDigitsOfLength(serial, 4) || (commercial && entry.group("region").isEmpty())) {
            return PlateValidation.invalid(REASON_INCOMPLETE)
        }
        val digits = cls.length
        if (!isDigits(cls) || digits < 2 || digits > 3 || (digits == 3 && commercial)) {
            return PlateValidation.invalid(REASON_CLASS)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_INCOMPLETE = "Every field must be filled."
        const val REASON_CLASS = "The class number is out of range."
        const val REASON_DIPLOMATIC = "A diplomatic plate is two groups of three digits."
        const val REASON_US_FORCES = "A US Forces plate is one digit and four digits."
    }
}

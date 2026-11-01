package plates.countries.niger

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

private val regions = ('1'..'8').map { it.toString() }
private val series = ('A'..'Z').map { it.toString() }

/** Judges a `NigerPlates` value: region digit 1-8, one series letter, a four-digit serial. */
class NigerValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) =
        validateFields(entry.group("region"), entry.group("series"), entry.group("serial"))

    companion object {
        const val REASON_REGION = "The region is a digit from 1 to 8."
        const val REASON_SERIES = "The series is one letter."
        const val REASON_SERIAL = "The serial is four digits."

        fun validateFields(region: String, series: String, serial: String): PlateValidation {
            if (region !in regions) return PlateValidation.invalid(REASON_REGION)
            if (series !in plates.countries.niger.series) return PlateValidation.invalid(REASON_SERIES)
            if (!isDigitsOfLength(serial, 4)) return PlateValidation.invalid(REASON_SERIAL)
            return PlateValidation.valid
        }
    }
}

/** `12345ARN6`: five digits, the fixed `ARN`, and a region digit. */
class NigerStateValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("serial"), 5)) return PlateValidation.invalid("The serial is five digits.")
        if (entry.group("area") !in regions) return PlateValidation.invalid(NigerValidator.REASON_REGION)
        return PlateValidation.valid
    }
}

class NigerMilitaryValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) =
        if (isDigitsOfLength(entry.group("serial"), 5)) PlateValidation.valid
        else PlateValidation.invalid("The serial is five digits.")
}

/** `123CMD RN` and `123CD4 RN`: a three-digit country code, and for staff a further digit the article calls the room. */
class NigerDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "code"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("code"), 3)) return PlateValidation.invalid("The country code is three digits.")
        val room = entry.group("room")
        if (room.isNotEmpty() && !isDigitsOfLength(room, 1)) return PlateValidation.invalid("The room is one digit.")
        return PlateValidation.valid
    }
}

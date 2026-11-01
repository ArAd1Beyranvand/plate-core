package plates.countries.vietnam

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

// VietnamMissions: the 336-340 block is refused on a diplomatic plate.
private const val NOT_FOUND = "COUNTRY NOT FOUND"
private val refusedMissions = listOf("336", "337", "338", "339", "340")

/** The number, whole: a dot or dash splits it into `number`, `number2`. */
private fun wholeNumber(entry: PlateEntry): String =
    entry.group("number") + entry.group("number2") + entry.group("number3")

/** Judges a civil, temporary or motorcycle plate: a province code, a series and a number. Reports, never bars a keystroke. */
class VietnamValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val province = entry.group("province")
        val code = province.toIntOrNull()
        if (province.length != 2 || code == null || code < 11) {
            return PlateValidation.invalid(REASON_PROVINCE)
        }
        if (entry.group("series").isEmpty()) return PlateValidation.invalid(REASON_SERIES)
        val number = wholeNumber(entry)
        if (number.length != 5 || !isDigits(number)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PROVINCE = "The province code is 11 to 99."
        const val REASON_SERIES = "The series is missing."
        const val REASON_NUMBER = "The number is 5 digits."
    }
}

/** Judges a diplomatic, international-organisation or foreigner plate: the province, a three-digit mission code and a two-digit number. */
class VietnamForeignValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val mission = entry.group("mission")
        if (mission in refusedMissions) return PlateValidation.invalid(NOT_FOUND)
        if (mission.length != 3 || !isDigits(mission)) return PlateValidation.invalid(REASON_MISSION)
        val number = wholeNumber(entry)
        if (number.length != 2 || !isDigits(number)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_MISSION = "The mission code is three digits."
        const val REASON_NUMBER = "The number is two digits."
    }
}

/** Judges a military plate: a two-letter unit code and the number. */
class VietnamMilitaryValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("unit").length != 2) return PlateValidation.invalid(REASON_UNIT)
        val number = wholeNumber(entry)
        if (number.length < 3 || number.length > 4 || !isDigits(number)) {
            return PlateValidation.invalid(REASON_NUMBER)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_UNIT = "The unit code is two letters."
        const val REASON_NUMBER = "The number is 3 or 4 digits."
    }
}

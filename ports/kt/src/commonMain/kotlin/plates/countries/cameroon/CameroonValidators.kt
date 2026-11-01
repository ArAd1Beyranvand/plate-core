package plates.countries.cameroon

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: CameroonAlphabets.letters is A-Z.
private val series = Regex("^[A-Z]{1,2}$")

/** Judges a regular plate (`LT 128 AB`): region code, three or four digits, one- or two-letter series. */
class CameroonValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("region") !in regions) return PlateValidation.invalid(REASON_REGION)
        val number = entry.group("number")
        if (!isDigitsOfLength(number, 3) && !isDigitsOfLength(number, 4)) return PlateValidation.invalid(REASON_NUMBER)
        if (!series.matches(entry.group("series"))) return PlateValidation.invalid(REASON_SERIES)
        return PlateValidation.valid
    }

    companion object {
        val regions = setOf("AD", "CE", "EN", "ES", "LT", "NO", "NW", "OU", "SU", "SW")

        const val REASON_REGION = "The region is one of the ten region codes."
        const val REASON_NUMBER = "The number is three or four digits."
        const val REASON_SERIES = "The series is one or two letters."
    }
}

/** Judges a diplomatic plate (`CMD 38 2`). Only digit counts are checked; how codes split across the cells is undocumented. */
class CameroonDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("mission") != "CM" || entry.group("type") != "D") return PlateValidation.invalid(REASON_PREFIX)
        if (!isDigitsOfLength(entry.group("number"), 2)) return PlateValidation.invalid(REASON_NUMBER)
        if (!isDigitsOfLength(entry.group("suffix"), 1)) return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is CMD."
        const val REASON_NUMBER = "The mission code is two digits."
        const val REASON_SUFFIX = "The suffix is one digit."
    }
}

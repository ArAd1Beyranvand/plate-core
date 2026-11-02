package plates.countries.malaysia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

// H9: explicit class, portable across regex engines.
private val notIssued = Regex("[IO]")

/** Advisory validator for `MalaysiaPlates.singleRow`, `twoRow` and `ev`. I and O are never issued; the number runs 1-9999; a Sabah suffix is never Q or S. */
class MalaysiaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry) =
        validateFields(entry.group("prefix"), entry.group("number"), entry.group("suffix"))

    companion object {
        const val REASON_PREFIX_MISSING = "A plate starts with letters."
        const val REASON_NO_IO = "I and O are not issued on Malaysian plates."
        const val REASON_NUMBER = "The number is 1 to 9999."
        const val REASON_LEADING_ZERO = "The number has no leading zero."
        const val REASON_SABAH_SUFFIX = "A Sabah suffix is never Q or S."

        fun validateFields(prefix: String, number: String, suffix: String = ""): PlateValidation {
            if (prefix.isEmpty()) return PlateValidation.invalid(REASON_PREFIX_MISSING)
            if (notIssued.containsMatchIn(prefix + suffix)) return PlateValidation.invalid(REASON_NO_IO)
            if (number.isEmpty() || number.length > 4 || !isDigits(number)) return PlateValidation.invalid(REASON_NUMBER)
            if (number.startsWith("0")) return PlateValidation.invalid(REASON_LEADING_ZERO)
            if (prefix.startsWith("S") && (suffix == "Q" || suffix == "S")) return PlateValidation.invalid(REASON_SABAH_SUFFIX)
            return PlateValidation.valid
        }
    }
}

/** Advisory validator for `MalaysiaPlates.diplomatic`: two two-digit numbers and a mission code. */
class MalaysiaDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "mission"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("country"), 2) || !isDigitsOfLength(entry.group("serial"), 2)) {
            return PlateValidation.invalid(REASON_DIGITS)
        }
        if (entry.group("mission") !in missions) return PlateValidation.invalid(REASON_MISSION)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_DIGITS = "Both numbers are two digits."
        const val REASON_MISSION = "The code is DC, CC, UN or PA."

        private val missions = setOf("DC", "CC", "UN", "PA")
    }
}

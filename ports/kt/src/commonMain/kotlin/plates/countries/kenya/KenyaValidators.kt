package plates.countries.kenya

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isLetters

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val oneToThreeDigits = Regex("^[0-9]{1,3}$")

private const val MISSION_NOT_FOUND = "COUNTRY NOT FOUND"
private val refusedMissions = listOf("24")

/** Judges a 2022 plate (`KDK 101A`). Reports, never bars a keystroke. */
class KenyaValidator : GatedPlateValidator() {
    override val gateGroup = "suffix"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isLetters(entry.group("letters"), 3)) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(entry.group("digits"), 3)) return PlateValidation.invalid(REASON_DIGITS)
        if (!isLetters(entry.group("suffix"), 1)) return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The register is three letters."
        const val REASON_DIGITS = "The number is three digits."
        const val REASON_SUFFIX = "The number ends in a letter."
    }
}

/** Judges a diplomatic plate (`1 CD 1 AK`). Refuses mission `24` on its own account too. */
class KenyaDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "letters"

    override fun validate(entry: PlateEntry): PlateValidation {
        if (entry.group("mission") in refusedMissions) return PlateValidation.invalid(MISSION_NOT_FOUND)
        return super.validate(entry)
    }

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!oneToThreeDigits.matches(entry.group("mission"))) return PlateValidation.invalid(REASON_MISSION)
        if (entry.group("type").isEmpty()) return PlateValidation.invalid(REASON_TYPE)
        if (!oneToThreeDigits.matches(entry.group("digits"))) return PlateValidation.invalid(REASON_DIGITS)
        if (!isLetters(entry.group("letters"), 2)) return PlateValidation.invalid(REASON_LETTERS)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_MISSION = "The mission is one to three digits."
        const val REASON_TYPE = "Pick CD or UN."
        const val REASON_DIGITS = "The serial is one to three digits."
        const val REASON_LETTERS = "The register is two letters."
    }
}

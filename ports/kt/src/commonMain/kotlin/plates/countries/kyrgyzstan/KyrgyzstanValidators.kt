package plates.countries.kyrgyzstan

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

private val twoOrThreeLetters = Regex("^[A-Z]{2,3}$")
private val regionCodes = (1..11).map { it.toString().padStart(2, '0') }
private val foreignClasses = listOf("H", "K", "M", "P")
private val diplomaticClasses = listOf("C", "D", "T")
private val missionCodes = (1..19).map { it.toString().padStart(2, '0') } + (50..64).map { it.toString() }

private fun month(value: String): Boolean {
    val m = value.toIntOrNull()
    return value.length == 2 && m != null && m in 1..12
}

/** Judges the `01 | 123 ABC` plates by their groups `region`, `number`, `letters`. */
class KyrgyzstanValidator : GatedPlateValidator() {
    override val gateGroup = "letters"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("region") !in regionCodes) return PlateValidation.invalid(REASON_REGION)
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_NUMBER)
        if (!twoOrThreeLetters.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_REGION = "The region code is 01 to 11."
        const val REASON_NUMBER = "The number is three digits."
        const val REASON_LETTERS = "The serial ends in two or three letters."
    }
}

/** Judges the yellow foreign plate: `01 | 1234 H`, the letter one of H, K, M or P. */
class KyrgyzstanForeignValidator : GatedPlateValidator() {
    override val gateGroup = "letters"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("region") !in regionCodes) return PlateValidation.invalid(REASON_REGION)
        if (!isDigitsOfLength(entry.group("number"), 4)) return PlateValidation.invalid(REASON_NUMBER)
        if (entry.group("letters") !in foreignClasses) return PlateValidation.invalid(REASON_LETTER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_REGION = "The region code is 01 to 11."
        const val REASON_NUMBER = "The number is four digits."
        const val REASON_LETTER = "The class letter is H, K, M or P."
    }
}

/** Judges the white-on-colour plates: `D 01 001`, `HC 1001` (dated) and `CMD 001` (undated). */
class KyrgyzstanDiplomaticValidator(
    val classes: List<String>,
    val numberLength: Int,
    val hasMission: Boolean = false,
    val dated: Boolean = false,
) : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("class") !in classes) return PlateValidation.invalid(REASON_CLASS)
        if (hasMission && entry.group("mission") !in missionCodes) return PlateValidation.invalid(REASON_MISSION)
        if (!isDigitsOfLength(entry.group("number"), numberLength)) return PlateValidation.invalid(REASON_NUMBER)
        if (dated) {
            if (!month(entry.group("month"))) return PlateValidation.invalid(REASON_MONTH)
            if (!isDigitsOfLength(entry.group("year"), 2)) return PlateValidation.invalid(REASON_YEAR)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_CLASS = "The class is not one this plate uses."
        const val REASON_MISSION = "The mission code is 01 to 19 (countries) or 50 to 64 (organisations)."
        const val REASON_NUMBER = "The number has the wrong length."
        const val REASON_MONTH = "The month is 01 to 12."
        const val REASON_YEAR = "The year is two digits."

        val diplomatic = KyrgyzstanDiplomaticValidator(diplomaticClasses, 3, hasMission = true, dated = true)
        val honorary = KyrgyzstanDiplomaticValidator(listOf("HC"), 4, dated = true)
        val mission = KyrgyzstanDiplomaticValidator(listOf("CMD"), 3)
    }
}

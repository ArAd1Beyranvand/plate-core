package plates.countries.iranshahr

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isLetters

private const val NOT_FOUND = "COUNTRY NOT FOUND"
private val refusedMissions = listOf("007")
private val regionCodes = (1..20).map { it.toString().padStart(2, '0') }
private val missions = setOf(
    "001", "002", "003", "004", "005", "006", "008", "009", "010", "011", "012", "013", "014", "015", "016", "017",
    "018", "019", "020", "021", "022", "023", "024", "025", "026", "027", "028", "029", "031", "032", "033", "034",
    "035", "036", "037", "038", "039", "040",
)

/** Judges `573 ABX | 15`: three digits, [letters] letters, then a two-digit region code 01-20. Gated on the region. */
class KazakhstanValidator(val letters: Int = 3) : GatedPlateValidator() {
    override val gateGroup = "region"

    private val lettersPattern = Regex("^[A-Z]{$letters}$")

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_NUMBER)
        if (!lettersPattern.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        if (entry.group("region") !in regionCodes) return PlateValidation.invalid(REASON_REGION)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is three digits."
        const val REASON_LETTERS = "The serial has the wrong number of letters."
        const val REASON_REGION = "The region code is 01 to 20."
    }
}

/** Judges the diplomatic plate `D 001 618`; refuses `007` on its own account as well as through the spec's restriction. */
class KazakhstanDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun validate(entry: PlateEntry): PlateValidation {
        if (entry.group("mission") in refusedMissions) return PlateValidation.invalid(NOT_FOUND)
        return super.validate(entry)
    }

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isLetters(entry.group("class"), 1)) return PlateValidation.invalid(REASON_CLASS)
        if (entry.group("mission") !in missions) return PlateValidation.invalid(NOT_FOUND)
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_CLASS = "The class is one letter."
        const val REASON_NUMBER = "The number is three digits."
    }
}

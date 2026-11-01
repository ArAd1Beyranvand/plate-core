package plates.countries.ethiopia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

private fun letters(s: String, n: Int) = Regex("^[A-Z]{$n}$").matches(s)

private fun geezCount(s: String) = s.codePointCountCompat()

// Code points, not UTF-16 units; Ge'ez is BMP but stay faithful to Dart runes.
private fun String.codePointCountCompat(): Int = count { !it.isLowSurrogate() }

// Inlined from ethiopia_missions.dart.
private const val NOT_FOUND = "COUNTRY NOT FOUND"
private val refusedMissions = listOf("84")

/** Judges the 2026 private plate: six digits. Reports, never bars a keystroke. */
class EthiopiaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry) =
        if (isDigitsOfLength(entry.group("number"), 6)) PlateValidation.valid
        else PlateValidation.invalid(REASON_NUMBER)

    companion object {
        const val REASON_NUMBER = "The number is six digits."
    }
}

/** Judges the regional plate: a one-digit class, two Ge'ez letters, six digits and the two-letter Latin region code. */
class EthiopiaRegionalValidator : GatedPlateValidator() {
    override val gateGroup = "code"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("class"), 1)) return PlateValidation.invalid(REASON_CLASS)
        if (geezCount(entry.group("geez")) != 2) return PlateValidation.invalid(REASON_GEEZ)
        if (!isDigitsOfLength(entry.group("number"), 6)) return PlateValidation.invalid(REASON_NUMBER)
        if (!letters(entry.group("code"), 2)) return PlateValidation.invalid(REASON_CODE)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_CLASS = "The class is one digit."
        const val REASON_GEEZ = "The region is two Ge'ez letters."
        const val REASON_NUMBER = "The number is six digits."
        const val REASON_CODE = "The region code is two letters."
    }
}

/** Judges the diplomatic plate; refuses mission code `84` on its own account, even without the spec's restriction. */
class EthiopiaDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "type"

    override fun validate(entry: PlateEntry): PlateValidation {
        if (entry.group("mission") in refusedMissions) return PlateValidation.invalid(NOT_FOUND)
        return super.validate(entry)
    }

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("mission"), 2)) return PlateValidation.invalid(REASON_MISSION)
        if (geezCount(entry.group("series")) != 2) return PlateValidation.invalid(REASON_GEEZ)
        if (!isDigitsOfLength(entry.group("number"), 4)) return PlateValidation.invalid(REASON_NUMBER)
        if (!letters(entry.group("type"), 2)) return PlateValidation.invalid(REASON_TYPE)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_MISSION = "The mission code is two digits."
        const val REASON_GEEZ = "The series is two Ge'ez letters."
        const val REASON_NUMBER = "The number is four digits."
        const val REASON_TYPE = "The type is two letters."
    }
}

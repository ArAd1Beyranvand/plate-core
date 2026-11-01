package plates.countries.north_macedonia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.isDigitsOfLength
import plates.core.validators.restrictionVerdict

private val areas = listOf(
    "BE", "BT", "DB", "DE", "DH", "DK", "GE", "GV", "KA", "KI", "KO", "KR", "KP", "KS", "KU", "MB", "MK",
    "NE", "OH", "PE", "PP", "PS", "RA", "RE", "SK", "SN", "SU", "SR", "ST", "TE", "VA", "VE", "VI", "VV",
)

// mk.letters: A-Z without Q W X Y.
private val seriesLetters = ('A'..'Z').filter { it !in "QWXY" }.map { it.toString() }

/**
 * Judges a North Macedonian plate by its keyed groups. Reports, never bars a keystroke; quiet until the last field has content.
 *
 * - `mk.standard`, `mk.legacy`, `mk.two_row`: `region` (one of the 34 area codes), `digits` (four) and `letters` (two).
 * - `mk.diplomatic`: `mission` (a two-digit code), `type` (`CC`, `CD` or `CMD`) and `serial` (two or three digits).
 */
class NorthMacedoniaValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        val diplomatic = entry.spec.id == "mk.diplomatic"
        val gate = if (diplomatic) "serial" else "letters"
        restrictionVerdict(entry)?.let { return it }
        if (entry.group(gate).isEmpty()) return PlateValidation.valid
        return if (diplomatic) judgeDiplomatic(entry) else judgeStandard(entry)
    }

    private fun judgeStandard(entry: PlateEntry): PlateValidation {
        if (entry.group("region") !in areas) return PlateValidation.invalid(REASON_REGION)
        if (!isDigitsOfLength(entry.group("digits"), 4)) return PlateValidation.invalid(REASON_DIGITS)
        return ok(letters(entry.group("letters"), 2), REASON_LETTERS)
    }

    private fun judgeDiplomatic(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("mission"), 2)) return PlateValidation.invalid(REASON_MISSION)
        if (entry.group("type") !in types) return PlateValidation.invalid(REASON_TYPE)
        val serial = entry.group("serial")
        return ok(isDigitsOfLength(serial, 2) || isDigitsOfLength(serial, 3), REASON_SERIAL)
    }

    private fun ok(ok: Boolean, reason: String) = if (ok) PlateValidation.valid else PlateValidation.invalid(reason)

    private fun letters(v: String, n: Int) = v.length == n && v.all { it.toString() in seriesLetters }

    companion object {
        const val REASON_REGION = "The area code is not one in use."
        const val REASON_DIGITS = "The number is four digits."
        const val REASON_LETTERS = "The series is two letters."
        const val REASON_MISSION = "The mission code is not listed."
        const val REASON_TYPE = "The class is CC, CD or CMD."
        const val REASON_SERIAL = "The serial is two or three digits."

        private val types = listOf("CC", "CD", "CMD")
    }
}

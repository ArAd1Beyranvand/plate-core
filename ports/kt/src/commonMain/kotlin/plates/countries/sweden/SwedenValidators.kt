package plates.countries.sweden

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters = Regex("^[A-HJ-PR-UW-Z]{3}$")
private val last = Regex("^[0-9]{2}[0-9A-HJ-NPR-UW-Z]$")
private val mission = Regex("^[A-HJ-NPR-UW-Z]{2}$")
private val status = Regex("^[A-I]$")

/**
 * A registration is three letters, two digits and a digit or letter; a dealer plate is three letters and three
 * digits; a diplomatic plate is a two-letter mission code, three digits and a status letter A-I; a military plate is
 * four to six digits. Reports, never bars a keystroke; the one refusal is the diplomatic spec's restriction.
 */
class SwedenValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val number = entry.group("number")
        val code = entry.group("code")
        if (code.isNotEmpty()) {
            if (!mission.matches(code)) return PlateValidation.invalid(REASON_CODE)
            if (!isDigitsOfLength(number, 3)) return PlateValidation.invalid(REASON_DIGITS)
            if (!status.matches(entry.group("status"))) return PlateValidation.invalid(REASON_STATUS)
            return PlateValidation.valid
        }
        val lettersValue = entry.group("letters")
        if (lettersValue.isEmpty()) {
            if (!isDigits(number) || number.length < 4 || number.length > 6) return PlateValidation.invalid(REASON_MILITARY)
            return PlateValidation.valid
        }
        if (!letters.matches(lettersValue)) return PlateValidation.invalid(REASON_LETTERS)
        // Dealer plates (three digits) and registrations (two digits and a last character) both pass; the temporary
        // plate's last field is a letter.
        if (!isDigitsOfLength(number, 3) && !last.matches(number)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The letters are three, none of I, Q, V, Å, Ä, Ö."
        const val REASON_NUMBER = "The number is two digits and a digit or a letter (not O)."
        const val REASON_DIGITS = "The number is three digits."
        const val REASON_CODE = "The mission code is two letters (no I, O, Q, V)."
        const val REASON_STATUS = "The status letter is A to I."
        const val REASON_MILITARY = "The number is four to six digits."
    }
}

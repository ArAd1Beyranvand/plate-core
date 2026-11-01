package plates.countries.bosnia_and_herzegovina

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/**
 * Judges a plate by its groups. Reports, never bars a keystroke.
 *
 * A private or agricultural serial is `X00-X-000`: a digit or one of `A E J K M O T`, two digits, one of those
 * letters, three digits. Taxi, temporary and EUPM plates carry fixed text and are judged on six or four digits;
 * a diplomatic plate is a two-digit code from 10 to 49 (not 31), a letter and three digits.
 */
class BosniaAndHerzegovinaValidator : GatedPlateValidator() {
    override val gateGroup = "digits"

    override fun judge(entry: PlateEntry): PlateValidation {
        val digits = entry.group("digits")
        val prefix = entry.group("prefix")
        val letter = entry.group("letter")
        val code = entry.group("code")
        if (code.isNotEmpty()) {
            val n = code.toIntOrNull()
            val ok = n != null && n in 10..49 && n != 31 && letter.length == 1 && isDigitsOfLength(digits, 3)
            return if (ok) PlateValidation.valid else PlateValidation.invalid(REASON_DIPLOMATIC)
        }
        if (prefix.isNotEmpty()) {
            val ok = prefix.length == 3 && letter.length == 1 && isDigitsOfLength(digits, 3)
            return if (ok) PlateValidation.valid else PlateValidation.invalid(REASON_SERIAL)
        }
        if (isDigitsOfLength(digits, 6)) return PlateValidation.valid
        return if (isDigitsOfLength(digits, 4)) PlateValidation.valid else PlateValidation.invalid(REASON_SIX)
    }

    companion object {
        const val REASON_SERIAL = "A plate is X00-X-000."
        const val REASON_SIX = "The plate carries six digits."
        const val REASON_FOUR = "An EUPM plate carries four digits."
        const val REASON_DIPLOMATIC = "A diplomatic plate is a code from 10 to 49, a letter and three digits."
    }
}

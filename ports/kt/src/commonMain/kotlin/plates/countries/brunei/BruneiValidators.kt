package plates.countries.brunei

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

/**
 * Judges a `BruneiPlates.singleRow` registration. Reports, never bars a keystroke.
 *
 * Series run `B 1`–`BZZ 9999` and `KA 1`–`KP 9999`: a prefix starts with B or K, a lone K is never issued,
 * a K series' second letter is A–P, I and O are never issued, and the number is 1–9999 without leading zero.
 * `MOD` plus a number and branch letter is exempt from the letter rules. Released prefixes and royal vanity
 * plates are not checked.
 */
class BruneiValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry) =
        validateFields(entry.group("prefix"), entry.group("number"), entry.group("suffix"))

    companion object {
        const val MILITARY = "MOD"

        const val REASON_PREFIX_MISSING = "A plate starts with letters."
        const val REASON_SERIES = "A plate starts with B or K, or is MOD."
        const val REASON_LONE_K = "There is no plate with the single letter K."
        const val REASON_K_SERIES = "A K series runs from KA to KP."
        const val REASON_NO_IO = "I and O are not issued on Brunei plates."
        const val REASON_NUMBER = "The number is 1 to 9999."
        const val REASON_LEADING_ZERO = "The number has no leading zero."
        const val REASON_SUFFIX = "Only a MOD plate has a branch letter."

        fun validateFields(prefix: String, number: String, suffix: String = ""): PlateValidation {
            if (prefix.isEmpty()) return PlateValidation.invalid(REASON_PREFIX_MISSING)
            if (prefix != MILITARY) {
                if (prefix[0] != 'B' && prefix[0] != 'K') return PlateValidation.invalid(REASON_SERIES)
                if ((prefix + suffix).any { it == 'I' || it == 'O' }) return PlateValidation.invalid(REASON_NO_IO)
                if (prefix[0] == 'K') {
                    if (prefix.length == 1) return PlateValidation.invalid(REASON_LONE_K)
                    if (prefix[1] > 'P') return PlateValidation.invalid(REASON_K_SERIES)
                }
                if (suffix.isNotEmpty()) return PlateValidation.invalid(REASON_SUFFIX)
            }
            if (number.isEmpty() || number.length > 4 || !isDigits(number)) return PlateValidation.invalid(REASON_NUMBER)
            if (number.startsWith("0")) return PlateValidation.invalid(REASON_LEADING_ZERO)
            return PlateValidation.valid
        }
    }
}

/** Judges a `BruneiPlates.diplomatic` value: two numbers of one or two digits. No ranges are documented. */
class BruneiDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "mission"

    override fun judge(entry: PlateEntry): PlateValidation {
        for (part in listOf(entry.group("serial"), entry.group("mission"))) {
            if (part.isEmpty() || part.length > 2 || !isDigits(part)) return PlateValidation.invalid(REASON_DIGITS)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_DIGITS = "Each number is one or two digits."
    }
}

package plates.countries.timor_leste

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

/** A current plate: five digits as `NN·NNN`, and on a government plate the letter `G`. No ranges are published, so none are checked. Reports, never bars. */
class TimorLesteValidator : GatedPlateValidator() {
    override val gateGroup = "second"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("first"), 2) || !isDigitsOfLength(entry.group("second"), 3)) {
            return PlateValidation.invalid(REASON_DIGITS)
        }
        val suffix = entry.group("suffix")
        if (suffix.isNotEmpty() && suffix != "G") return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_DIGITS = "The number is five digits, NN·NNN."
        const val REASON_SUFFIX = "A government plate ends in G."
    }
}

/** An expiry `MMYY` (month 01-12), the code `DF`, 1-4 digits and up to two letters. The expiry's year is not range-checked. */
class TimorLesteIndonesianValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val expiry = entry.group("expiry")
        val month = (if (expiry.length == 4) expiry.substring(0, 2) else "").toIntOrNull() ?: 0
        if (!isDigitsOfLength(expiry, 4) || month < 1 || month > 12) return PlateValidation.invalid(REASON_EXPIRY)
        if (entry.group("prefix") != "DF") return PlateValidation.invalid(REASON_REGION)
        val number = entry.group("number")
        if (number.isEmpty() || number.length > 4 || !isDigits(number)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_EXPIRY = "The expiry is a month 01–12 and a year."
        const val REASON_REGION = "East Timor plates carry the code DF."
        const val REASON_NUMBER = "The number is 1 to 4 digits."
    }
}

/** The prefix `T` or `TP` and `NN-NN`. */
class TimorLestePortugueseValidator : GatedPlateValidator() {
    override val gateGroup = "second"

    override fun judge(entry: PlateEntry): PlateValidation {
        val prefix = entry.group("prefix")
        if (prefix != "T" && prefix != "TP") return PlateValidation.invalid(REASON_PREFIX)
        if (!isDigitsOfLength(entry.group("first"), 2) || !isDigitsOfLength(entry.group("second"), 2)) {
            return PlateValidation.invalid(REASON_DIGITS)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is T or TP."
        const val REASON_DIGITS = "The number is four digits, NN-NN."
    }
}

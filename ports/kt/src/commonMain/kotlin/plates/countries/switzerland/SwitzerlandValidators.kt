package plates.countries.switzerland

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

/** The 26 cantons' two-letter codes. */
val switzerlandCantons = listOf(
    "AG", "AI", "AR", "BE", "BL", "BS", "FR", "GE", "GL", "GR", "JU", "LU", "NE",
    "NW", "OW", "SG", "SH", "SO", "SZ", "TG", "TI", "UR", "VD", "VS", "ZG", "ZH",
)

// SwitzerlandMissions: code 7 is refused, with or without leading zeros.
private const val NOT_FOUND = "COUNTRY NOT FOUND"
private val refused = listOf("7", "07", "007")

private fun isPlain(s: String) = isDigits(s) && !s.startsWith("0")

/**
 * Judges a canton-and-number plate. Reports, never bars a keystroke; gated on the number. The canton is one of
 * [switzerlandCantons] (a [military] plate may instead open with a lone M), and the number is digits with no leading zero.
 */
class SwitzerlandValidator(val military: Boolean = false) : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val canton = entry.group("canton")
        if (canton !in switzerlandCantons && !(military && canton == "M")) return PlateValidation.invalid(REASON_CANTON)
        if (!isPlain(entry.group("number"))) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_CANTON = "The canton is a Swiss canton code."
        const val REASON_NUMBER = "The number is digits without a leading 0."
    }
}

/** Judges a diplomatic or consular value: a canton, a serial and a country code, none with a leading zero; code 7 is refused on its own account. */
class SwitzerlandDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "code"

    override fun validate(entry: PlateEntry): PlateValidation {
        if (entry.group("code") in refused) return PlateValidation.invalid(NOT_FOUND)
        return super.validate(entry)
    }

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("canton") !in switzerlandCantons) return PlateValidation.invalid(SwitzerlandValidator.REASON_CANTON)
        if (!isPlain(entry.group("serial"))) return PlateValidation.invalid(REASON_SERIAL)
        if (!isPlain(entry.group("code"))) return PlateValidation.invalid(REASON_CODE)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_SERIAL = "The serial is one to three digits."
        const val REASON_CODE = "The code is one to three digits."
    }
}

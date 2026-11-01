package plates.countries.vatican_city

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

private val digits = Regex("^[0-9]+$")
private val letter = Regex("^[A-Z]$")

/** Judges a Vatican plate: `CV` (resident) or `SCV` (State) followed by digits, and on an official plate one trailing letter. */
class VaticanCityValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val prefix = entry.group("prefix")
        if (prefix != "CV" && prefix != "SCV") return PlateValidation.invalid(REASON_PREFIX)
        if (!digits.matches(entry.group("number"))) return PlateValidation.invalid(REASON_NUMBER)
        val suffix = entry.group("suffix")
        if (suffix.isNotEmpty() && !letter.matches(suffix)) return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is CV or SCV."
        const val REASON_NUMBER = "The number is digits."
        const val REASON_SUFFIX = "The suffix is one letter."
    }
}

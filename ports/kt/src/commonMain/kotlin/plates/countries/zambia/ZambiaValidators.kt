package plates.countries.zambia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Judges the plate (`ADD 4077 T`): three letters, four digits, one letter. Reports, never bars a keystroke. */
class ZambiaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!prefixRe.matches(entry.group("prefix"))) return PlateValidation.invalid(REASON_PREFIX)
        if (!isDigitsOfLength(entry.group("serial"), 4)) return PlateValidation.invalid(REASON_SERIAL)
        if (!suffixRe.matches(entry.group("suffix"))) return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is three letters."
        const val REASON_SERIAL = "The number is four digits."
        const val REASON_SUFFIX = "The suffix is one letter."

        private val prefixRe = Regex("^[A-Z]{3}$")
        private val suffixRe = Regex("^[A-Z]$")
    }
}

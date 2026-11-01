package plates.countries.caribbean

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

private val prefixRe = Regex("^[A-Z]{1,2}$")

/** Judges a `private` value: a one- or two-letter type prefix and up to four digits. */
class SintMaartenValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!prefixRe.matches(entry.group("prefix"))) return PlateValidation.invalid(REASON_PREFIX)
        val number = entry.group("number")
        if (number.isEmpty() || number.length > 4 || !isDigits(number)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is one or two letters."
        const val REASON_NUMBER = "The number is up to four digits."
    }
}

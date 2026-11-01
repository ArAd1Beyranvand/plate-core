package plates.countries.greece

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

/** Judges a registration on any Greek spec: the slot lengths per field, and a private car's number running 1000 to 9999. */
class GreeceValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val spec = entry.spec
        val letters = spec.slots[spec.indicesOfGroup("letters").single()]
        val number = spec.slots[spec.indicesOfGroup("number").single()]
        val prefix = entry.group("letters")
        val digits = entry.group("number")
        if (prefix.length < letters.minLength || prefix.length > letters.length || !letters.accepts(prefix)) {
            return PlateValidation.invalid(REASON_LETTERS)
        }
        if (!isDigits(digits) || digits.length < number.minLength || digits.length > number.length) {
            return PlateValidation.invalid(REASON_DIGITS)
        }
        if (spec.id == "gr.private" && digits.toInt() < 1000) return PlateValidation.invalid(REASON_RANGE)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The prefix is letters from Α Β Ε Ζ Η Ι Κ Μ Ν Ο Ρ Τ Υ Χ."
        const val REASON_DIGITS = "The number has the wrong digit count."
        const val REASON_RANGE = "Private numbers run from 1000 to 9999."
    }
}

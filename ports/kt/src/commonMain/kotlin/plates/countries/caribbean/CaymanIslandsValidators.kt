package plates.countries.caribbean

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Judges a `pair` or `taxi` value: two three-digit fields. */
class CaymanIslandsValidator : GatedPlateValidator() {
    override val gateGroup = "second"

    override fun judge(entry: PlateEntry) =
        if (isDigitsOfLength(entry.group("first"), 3) && isDigitsOfLength(entry.group("second"), 3)) {
            PlateValidation.valid
        } else {
            PlateValidation.invalid(REASON_DIGITS)
        }

    companion object {
        const val REASON_DIGITS = "A plate is two groups of three digits."
    }
}

/** Judges a `single` value: five digits. */
class CaymanIslandsSingleValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) =
        if (isDigitsOfLength(entry.group("serial"), 5)) PlateValidation.valid else PlateValidation.invalid(REASON_DIGITS)

    companion object {
        const val REASON_DIGITS = "The serial is five digits."
    }
}

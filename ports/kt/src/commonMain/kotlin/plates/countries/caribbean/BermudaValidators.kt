package plates.countries.caribbean

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isLetters

private val serial34 = Regex("^[0-9]{3,4}$")

/** Judges a `BermudaPlates.private` value: five digits. */
class BermudaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) =
        if (isDigitsOfLength(entry.group("serial"), 5)) PlateValidation.valid else PlateValidation.invalid(REASON_SERIAL)

    companion object {
        const val REASON_SERIAL = "The number is five digits."
    }
}

/** Judges a `BermudaPlates.prefixed` value: one to three letters, then three or four digits. */
class BermudaPrefixedValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isLetters(entry.group("letters"), 1, 3)) return PlateValidation.invalid(REASON_LETTERS)
        if (!serial34.matches(entry.group("serial"))) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The class prefix is one to three letters."
        const val REASON_SERIAL = "The number is three or four digits."
    }
}

/** Judges a `BermudaPlates.suffixed` value: three digits and a letter (`123Y`). */
class BermudaSuffixedValidator : GatedPlateValidator() {
    override val gateGroup = "letter"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("serial"), 3)) return PlateValidation.invalid(REASON_SERIAL)
        if (!isLetters(entry.group("letter"), 1)) return PlateValidation.invalid(REASON_LETTER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_SERIAL = "The number is three digits."
        const val REASON_LETTER = "The suffix is one letter."
    }
}

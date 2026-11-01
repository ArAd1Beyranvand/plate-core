package plates.countries.canada

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Judges a `CanadaPlates.federal` value: five digits. */
class CanadaFederalValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry) =
        if (isDigitsOfLength(entry.group("number"), 5)) PlateValidation.valid else PlateValidation.invalid(REASON_NUMBER)

    companion object {
        const val REASON_NUMBER = "A federal plate has five digits."
    }
}

/** Judges a `CanadaPlates.permit` value: a letter, then six digits. I, O, Q and U are reported as unused. */
class CanadaPermitValidator : GatedPlateValidator() {
    override val gateGroup = "letter"

    override fun judge(entry: PlateEntry): PlateValidation {
        val letter = entry.group("letter")
        if (letter.length != 1) return PlateValidation.invalid(REASON_LETTER)
        if (letter in "IOQU") return PlateValidation.invalid(REASON_UNUSED)
        if (!isDigitsOfLength(entry.group("number"), 6)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTER = "A permit starts with one letter."
        const val REASON_UNUSED = "I, O, Q and U are not used in serials."
        const val REASON_NUMBER = "A permit has six digits."
    }
}

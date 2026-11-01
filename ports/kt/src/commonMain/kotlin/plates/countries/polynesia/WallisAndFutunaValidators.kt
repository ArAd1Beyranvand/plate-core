package plates.countries.polynesia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Judges a Wallis and Futuna plate: a four-digit serial followed by the printed `WF`. Reports, never bars a keystroke. */
class WallisAndFutunaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry) =
        if (isDigitsOfLength(entry.group("number"), 4)) PlateValidation.valid else PlateValidation.invalid(REASON_NUMBER)

    companion object {
        const val REASON_NUMBER = "The serial is four digits."
    }
}

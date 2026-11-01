package plates.countries.burundi

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes.
private val letter = Regex("^[A-Z]$")

/** Judges a Burundian plate: a letter, four digits and a letter, `A 0412 A`. Reports, never bars a keystroke. */
class BurundiValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letter.matches(entry.group("prefix"))) return PlateValidation.invalid("The prefix is 1 letter.")
        if (!isDigitsOfLength(entry.group("number"), 4)) return PlateValidation.invalid("The number is 4 digits.")
        if (!letter.matches(entry.group("suffix"))) return PlateValidation.invalid("The suffix is 1 letter.")
        return PlateValidation.valid
    }
}

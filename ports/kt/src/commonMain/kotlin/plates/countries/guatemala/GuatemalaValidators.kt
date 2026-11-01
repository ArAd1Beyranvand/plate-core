package plates.countries.guatemala

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val classLetter = Regex("^[A-Z]$")
private val digits = Regex("^[0-9]{3}$")
private val letters = Regex("^[A-Z]{3}$")

/** Judges a Guatemalan serial `P 123 ABC`: a class letter, three digits and three letters. Reports, never bars a keystroke. */
class GuatemalaValidator : GatedPlateValidator() {
    override val gateGroup = "letters"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!classLetter.matches(entry.group("class"))) return PlateValidation.invalid(REASON_CLASS)
        if (!digits.matches(entry.group("digits"))) return PlateValidation.invalid(REASON_DIGITS)
        if (!letters.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_CLASS = "The class is one letter, such as P or C."
        const val REASON_DIGITS = "The number is three digits."
        const val REASON_LETTERS = "The serial ends in three letters."
    }
}

package plates.countries.gabon

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII class, portable across JVM/JS/Wasm regex engines.
private val twoLetters = Regex("^[A-Z]{2}$")

/** Judges `AB-123-CD`: two letters, three digits, two letters. Reports, never bars a keystroke. */
class GabonValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!twoLetters.matches(entry.group("series"))) return PlateValidation.invalid("The first group is 2 letters.")
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid("The number is 3 digits.")
        if (!twoLetters.matches(entry.group("suffix"))) return PlateValidation.invalid("The last group is 2 letters.")
        return PlateValidation.valid
    }
}

package plates.countries.benin

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val series = Regex("^[A-Z]{2}$")

/** Judges a Beninese plate: two letters (the series) and four digits, `AB 1234`. Reports, never bars a keystroke. */
class BeninValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!series.matches(entry.group("series"))) return PlateValidation.invalid("The series is 2 letters.")
        if (!isDigitsOfLength(entry.group("number"), 4)) return PlateValidation.invalid("The number is 4 digits.")
        return PlateValidation.valid
    }
}

package plates.countries.togo

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.restrictionVerdict

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val digits4 = Regex("^[0-9]{4}$")
private val letters2 = Regex("^[A-Z]{2}$")

/** Judges a Togolese plate field by field: `1234·AB`, four digits and a two-letter series. Quiet until the series has something in it. Reports, never bars a keystroke. */
class TogoValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        if (entry.group("series").isEmpty()) return PlateValidation.valid
        if (!digits4.matches(entry.group("number"))) return PlateValidation.invalid("The number is 4 digits.")
        if (!letters2.matches(entry.group("series"))) return PlateValidation.invalid("The series is 2 letters.")
        return PlateValidation.valid
    }
}

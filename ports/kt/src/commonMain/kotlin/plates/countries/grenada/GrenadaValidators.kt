package plates.countries.grenada

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.restrictionVerdict

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters = Regex("^[A-Z]{3}$")
private val digits = Regex("^[0-9]{3}$")

/** Judges a Grenadian plate: three letters then three digits. Quiet until the last field has something in it. */
class GrenadaValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        if (entry.group("number").isEmpty()) return PlateValidation.valid
        if (!letters.matches(entry.group("letters"))) return PlateValidation.invalid("The series is 3 letters.")
        if (!digits.matches(entry.group("number"))) return PlateValidation.invalid("The number is 3 digits.")
        return PlateValidation.valid
    }
}

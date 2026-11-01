package plates.countries.trinidad_and_tobago

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.restrictionVerdict

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters = Regex("^[A-HJ-NP-UW-Z]{1,3}$")
private val digits = Regex("^[0-9]{1,4}$")

/** Judges a Trinidad and Tobago plate field by field: one to three series letters (the first is the vehicle class) and one to four digits. I, O, Q and V are never issued in a series. Quiet until the letters have something in them. Reports, never bars a keystroke. */
class TrinidadAndTobagoValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        if (entry.group("letters").isEmpty()) return PlateValidation.valid
        if (!letters.matches(entry.group("letters"))) {
            return PlateValidation.invalid("The series is one to three letters, never I, O, Q or V.")
        }
        if (!digits.matches(entry.group("serial"))) return PlateValidation.invalid("The number is one to four digits.")
        return PlateValidation.valid
    }
}

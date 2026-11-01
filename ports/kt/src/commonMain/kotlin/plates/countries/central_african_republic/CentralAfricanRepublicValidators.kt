package plates.countries.central_african_republic

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters = Regex("^[A-Z]{2}$")

/** Judges a Central African plate: `BB 534 DG`, two letters, three digits (001-999), two letters naming the prefecture. Reports, never bars a keystroke. */
class CentralAfricanRepublicValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters.matches(entry.group("series"))) return PlateValidation.invalid("The series is 2 letters.")
        val serial = entry.group("serial")
        if (!isDigitsOfLength(serial, 3) || serial == "000") return PlateValidation.invalid("The number is 001 to 999.")
        if (!letters.matches(entry.group("prefecture"))) return PlateValidation.invalid("The prefecture is 2 letters.")
        return PlateValidation.valid
    }
}

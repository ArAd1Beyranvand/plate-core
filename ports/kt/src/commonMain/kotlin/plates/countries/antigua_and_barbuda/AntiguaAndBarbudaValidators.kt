package plates.countries.antigua_and_barbuda

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letter = Regex("^[A-Z]$")

/** Judges `A 1234`: one class letter and up to [maxDigits] digits (three on government plates). Reports, never bars a keystroke. */
class AntiguaAndBarbudaValidator(val maxDigits: Int = 4) : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letter.matches(entry.group("letter"))) return PlateValidation.invalid(REASON_LETTER)
        val serial = entry.group("serial")
        if (serial.isEmpty() || serial.length > maxDigits || !isDigits(serial)) {
            return PlateValidation.invalid("The number is one to $maxDigits digits.")
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTER = "The class is one letter."
    }
}

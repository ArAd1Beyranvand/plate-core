package plates.countries.seychelles

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letter = Regex("^[A-Z]$")
private val serial = Regex("^[0-9]{1,5}$")

/** Judges a plate (`S 11111`): one letter and up to five digits. Reports, never bars a keystroke. */
class SeychellesValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letter.matches(entry.group("letter"))) return PlateValidation.invalid(REASON_LETTER)
        if (!serial.matches(entry.group("serial"))) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTER = "The series is one letter."
        const val REASON_SERIAL = "The number is one to five digits."
    }
}

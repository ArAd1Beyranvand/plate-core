package plates.countries.tonga

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters = Regex("^[A-Z]{1,2}$")
private val serial = Regex("^[0-9]{1,5}$")

/** Judges a plate: a vehicle-type letter (two for `MC`) and one to five digits (`C 12345`). Reports, never bars a keystroke. */
class TongaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        if (!serial.matches(entry.group("serial"))) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The register is one or two letters."
        const val REASON_SERIAL = "The number is one to five digits."
    }
}

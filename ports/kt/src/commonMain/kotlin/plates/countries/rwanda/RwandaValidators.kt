package plates.countries.rwanda

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

// H9: explicit ASCII classes.
private val register = Regex("^R[A-Z]{2}$")
private val serial = Regex("^[0-9]{3}[A-Z]$")

/** Judges a plate `RXX ###X`: a register of three letters starting with `R`, then three digits and a letter. */
class RwandaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!register.matches(entry.group("register"))) return PlateValidation.invalid(REASON_REGISTER)
        if (!serial.matches(entry.group("serial"))) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_REGISTER = "The register is three letters starting with R."
        const val REASON_SERIAL = "The number is three digits and a letter."
    }
}

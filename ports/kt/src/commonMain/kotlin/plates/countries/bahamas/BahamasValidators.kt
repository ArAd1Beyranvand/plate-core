package plates.countries.bahamas

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letter = Regex("^[A-Z]$")

/** Judges a Bahamian registration: an optional class letter (`prefix`, the `T` of the truck series) and a numeric `serial` of up to five digits. Reports, never bars a keystroke. The 2016 format has no photograph and is not modelled. */
class BahamasValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) = validateFields(entry.group("prefix"), entry.group("serial"))

    companion object {
        const val MAX_SERIAL = 5

        const val REASON_SERIAL = "The serial is one to five digits."
        const val REASON_PREFIX = "The class prefix is one letter."

        fun validateFields(prefix: String, serial: String): PlateValidation {
            if (prefix.isNotEmpty() && !letter.matches(prefix)) return PlateValidation.invalid(REASON_PREFIX)
            if (!isDigits(serial) || serial.length > MAX_SERIAL) return PlateValidation.invalid(REASON_SERIAL)
            return PlateValidation.valid
        }
    }
}

package plates.countries.uganda

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val series = Regex("^[A-Z]{2}$")
private val number = Regex("^[0-9]{4,5}$")

/** A two-letter series (`UP` police, `UU` prisons) and a serial of four or five digits. Reports, never bars a keystroke. */
class UgandaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!series.matches(entry.group("series"))) return PlateValidation.invalid(REASON_SERIES)
        if (!number.matches(entry.group("number"))) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_SERIES = "The series is two letters."
        const val REASON_NUMBER = "The number is four or five digits."
    }
}

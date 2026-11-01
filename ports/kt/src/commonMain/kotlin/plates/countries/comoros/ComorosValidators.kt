package plates.countries.comoros

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val number = Regex("^[0-9]{3,4}$")
private val series = Regex("^[A-Z]$")
private val code = Regex("^[0-9]{2}$")

/** Judges a `ComorosPlates` value: three or four digits, a letter and two digits (`1284 A 73`). Reports, never bars a keystroke. */
class ComorosPlateValidator : GatedPlateValidator() {
    override val gateGroup = "code"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!number.matches(entry.group("number"))) return PlateValidation.invalid(REASON_NUMBER)
        if (!series.matches(entry.group("series"))) return PlateValidation.invalid(REASON_SERIES)
        if (!code.matches(entry.group("code"))) return PlateValidation.invalid(REASON_CODE)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is three or four digits."
        const val REASON_SERIES = "The series is one letter."
        const val REASON_CODE = "The code is two digits."
    }
}

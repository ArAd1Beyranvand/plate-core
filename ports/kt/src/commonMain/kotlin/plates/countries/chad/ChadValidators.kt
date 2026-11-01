package plates.countries.chad

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letter = Regex("^[A-Z]$")

/** Judges a Chadian plate: `12 V 3456 B`, region 01-23, a type letter, four digits and a series letter (`TT` on a temporary plate). Reports, never bars a keystroke. */
class ChadValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val regionText = entry.group("region")
        val region = regionText.toIntOrNull()
        if (!isDigitsOfLength(regionText, 2) || region == null || region < 1 || region > 23) {
            return PlateValidation.invalid("The region is 01 to 23.")
        }
        if (!letter.matches(entry.group("type"))) {
            return PlateValidation.invalid("The vehicle type is 1 letter (B, C, M, P, S, T, V).")
        }
        if (!isDigitsOfLength(entry.group("number"), 4)) return PlateValidation.invalid("The number is 4 digits.")
        val tail = entry.group("tail")
        if (tail.isNotEmpty() && !letter.matches(tail) && tail != "TT") {
            return PlateValidation.invalid("The series is 1 letter, or TT on a temporary plate.")
        }
        return PlateValidation.valid
    }
}

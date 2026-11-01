package plates.countries.chile

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII class, portable across JVM/JS/Wasm regex engines.
private val letters = Regex("^[A-Z]{3}$")

/** Judges an `ABC 123` plate: three Latin capitals and three digits. Reports, never bars a keystroke. */
class EasterIslandValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The plate starts with three letters."
        const val REASON_NUMBER = "The number is three digits."
    }
}

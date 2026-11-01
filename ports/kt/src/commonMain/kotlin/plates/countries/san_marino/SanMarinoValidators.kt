package plates.countries.san_marino

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val prefix = Regex("^[A-Z]{1,7}$")
private val number = Regex("^[0-9]{1,4}$")

/** Judges a San Marino plate: a `prefix` of one to seven letters and a `number` of one to four digits. */
class SanMarinoValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!prefix.matches(entry.group("prefix"))) return PlateValidation.invalid(REASON_PREFIX)
        if (!number.matches(entry.group("number"))) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is one to seven letters."
        const val REASON_NUMBER = "The number is one to four digits."
    }
}

package plates.countries.brazil

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val series = Regex("^[A-Z]{3}$")
private val number = Regex("^[0-9][A-Z][0-9]{2}$")
private val legacyPlate = Regex("^[A-Z]{3}[0-9]{4}$")

/** Judges a `BrazilPlates` value, `LLL N L NN`. Reports, never bars a keystroke; series allocation is not checked. */
class BrazilPlateValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!series.matches(entry.group("series"))) return PlateValidation.invalid(REASON_SERIES)
        if (!number.matches(entry.group("number"))) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_SERIES = "The series is three letters."
        const val REASON_NUMBER = "The number is a digit, a letter and two digits."

        /**
         * The Mercosul form of a 1990–2018 plate, `ABC1234` → `ABC1C34`: the second digit becomes a letter,
         * 0 → A through 9 → J. Null if [legacy] is not three letters and four digits.
         */
        fun fromLegacy(legacy: String): String? {
            if (!legacyPlate.matches(legacy)) return null
            val letter = 'A' + (legacy[4] - '0')
            return "${legacy.substring(0, 4)}$letter${legacy.substring(5)}"
        }
    }
}

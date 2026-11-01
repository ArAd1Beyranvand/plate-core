package plates.countries.republic_of_ireland

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

// H9: explicit ASCII class, portable across JVM/JS/Wasm regex engines.
private val year = Regex("^[0-9][0-9][12]$")

// Keys of RepublicOfIrelandAlphabets.countyNames.
private val countyCodes = setOf(
    "C", "CE", "CN", "CW", "D", "DL", "G", "KE", "KK", "KY", "L", "LD",
    "LH", "LM", "LS", "MH", "MN", "MO", "OY", "RN", "SO", "T", "W", "WH",
    "WX", "WW", "LK", "TN", "TS", "WD",
)

/** Judges a plate in the form `YYH-CC-NNNNN`: a year and half-year (`131` is the first half of 2013), a county code and a sequence of one to six digits. Reports, never bars a keystroke. */
class RepublicOfIrelandValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!year.matches(entry.group("year"))) return PlateValidation.invalid(REASON_YEAR)
        if (entry.group("county") !in countyCodes) return PlateValidation.invalid(REASON_COUNTY)
        val serial = entry.group("serial")
        if (!isDigits(serial) || serial.length > 6) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_YEAR = "The year is two digits and a half-year, 1 or 2."
        const val REASON_COUNTY = "That is not a county code."
        const val REASON_SERIAL = "The number is one to six digits."
    }
}

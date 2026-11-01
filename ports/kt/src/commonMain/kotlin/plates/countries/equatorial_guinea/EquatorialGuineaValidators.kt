package plates.countries.equatorial_guinea

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

private val series = Regex("^[A-Z]$")

/** Judges `AB-123-C`: province code, three digits, series letter. Reports, never bars a keystroke. */
class EquatorialGuineaValidator : GatedPlateValidator() {
    override val gateGroup = "series"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("province") !in provinces) {
            return PlateValidation.invalid("The province is one of ${provinces.joinToString(", ")}.")
        }
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid("The number is 3 digits.")
        if (!series.matches(entry.group("series"))) return PlateValidation.invalid("The series is 1 letter.")
        return PlateValidation.valid
    }

    companion object {
        val provinces = listOf("AN", "BN", "BS", "CS", "KN", "LT", "WN")
    }
}

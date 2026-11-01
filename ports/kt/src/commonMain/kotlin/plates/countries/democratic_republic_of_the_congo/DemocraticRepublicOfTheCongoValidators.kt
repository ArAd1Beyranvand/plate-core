package plates.countries.democratic_republic_of_the_congo

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

private val series = Regex("^[A-Z]{2}$")

/** Judges a private plate: `1234 AB 10`, four digits, two letters and a province code 01-26. */
class DemocraticRepublicOfTheCongoValidator : GatedPlateValidator() {
    override val gateGroup = "province"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("number"), 4)) return PlateValidation.invalid("The number is 4 digits.")
        if (!series.matches(entry.group("series"))) return PlateValidation.invalid("The series is 2 letters.")
        val province = entry.group("province")
        if (!isDigitsOfLength(province, 2) || province.toInt() !in 1..26) {
            return PlateValidation.invalid("The province code is 01 to 26.")
        }
        return PlateValidation.valid
    }
}

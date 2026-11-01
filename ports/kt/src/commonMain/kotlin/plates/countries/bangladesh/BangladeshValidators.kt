package plates.countries.bangladesh

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Judges a Bangladeshi car plate: city, class letter, a two-digit series of 11–99 and a four-digit number from 0001. Quiet until the number has something in it. Reports, never bars a keystroke. */
class BangladeshValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("city").isEmpty()) return PlateValidation.invalid("Choose a city.")
        if (entry.group("class").isEmpty()) return PlateValidation.invalid("Choose a vehicle class letter.")
        val series = entry.group("series")
        if (!isDigitsOfLength(series, 2) || series.toInt() < 11) return PlateValidation.invalid("The series is 11 to 99.")
        val number = entry.group("number")
        if (!isDigitsOfLength(number, 4) || number == "0000") return PlateValidation.invalid("The number is 0001 to 9999.")
        return PlateValidation.valid
    }
}

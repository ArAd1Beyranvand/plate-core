package plates.countries.republic_of_the_congo

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val series = Regex("^[A-Z]{2}$")

/** Judges a Congolese regular plate: `123 AB 4` — three digits, two letters and an area code of one or two digits (1–14). Reports, never bars input. */
class RepublicOfTheCongoValidator : GatedPlateValidator() {
    override val gateGroup = "area"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid("The number is 3 digits.")
        if (!series.matches(entry.group("series"))) return PlateValidation.invalid("The series is 2 letters.")
        val raw = entry.group("area")
        val area = if (isDigits(raw) && raw.length <= 9) raw.toInt() else null
        if (area == null || area < 1 || area > 14) return PlateValidation.invalid("The area code is 1 to 14.")
        return PlateValidation.valid
    }
}

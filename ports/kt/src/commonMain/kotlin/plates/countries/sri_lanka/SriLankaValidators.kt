package plates.countries.sri_lanka

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters = Regex("^[A-Z]{2,3}$")

/** Judges a Sri Lankan plate: a province code, two or three letters and four digits. Reports, never bars a keystroke. */
class SriLankaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("province") !in provinces) return PlateValidation.invalid(REASON_PROVINCE)
        if (!letters.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(entry.group("number"), 4)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PROVINCE = "The province is CP, EP, NC, NP, NW, SG, SP, UP or WP."
        const val REASON_LETTERS = "The series is two or three letters."
        const val REASON_NUMBER = "The number is four digits."

        val provinces = setOf("CP", "EP", "NC", "NP", "NW", "SG", "SP", "UP", "WP")
    }
}

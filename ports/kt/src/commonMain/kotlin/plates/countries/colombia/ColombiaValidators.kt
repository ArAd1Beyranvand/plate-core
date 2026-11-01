package plates.countries.colombia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val typeLetter = Regex("^[A-Z]$")
private val countryInitials = Regex("^[A-Z]{2}$")

/** The shape of one Colombian series: letters (with their fixed prefix) and digits. */
class ColombiaSeries(
    val id: String,
    val english: String,
    val letters: Int = 3,
    val digits: Int = 3,
    val digitsFirst: Boolean = false,
    val fixed: String = "",
) {
    companion object {
        val private = ColombiaSeries("private", "Private")
        val commercial = ColombiaSeries("commercial", "Public service")
        val official = ColombiaSeries("official", "Official", fixed = "O")
        val antiqueCar = ColombiaSeries("antique", "Antique car")
        val mototaxi = ColombiaSeries("mototaxi", "Auto rickshaw", digitsFirst = true)
        val trailer = ColombiaSeries("trailer", "Trailer", letters = 1, digits = 5, fixed = "R")
        val tankTruck = ColombiaSeries("tank", "Tank truck", letters = 1, digits = 4, fixed = "T")
        val consular = ColombiaSeries("cc", "Consular corps", letters = 2, digits = 4, fixed = "CC")
        val organization = ColombiaSeries("oi", "International organization", letters = 2, digits = 4, fixed = "OI")
        val staff = ColombiaSeries("at", "Non-diplomatic staff", letters = 2, digits = 4, fixed = "AT")

        val values = listOf(private, commercial, official, antiqueCar, mototaxi, trailer, tankTruck, consular, organization, staff)
    }
}

/** Judges a `ColombiaPlates.standard` value. Reports, never bars a keystroke. */
class ColombiaValidator(val series: ColombiaSeries = ColombiaSeries.private) : GatedPlateValidator() {
    override val gateGroup = if (series.digitsFirst) "letters" else "number"

    override fun judge(entry: PlateEntry) = validateFields(series, entry.group("letters"), entry.group("number"))

    companion object {
        fun validateFields(series: ColombiaSeries, letters: String, number: String): PlateValidation {
            if (!Regex("^[A-Z]{${series.letters}}$").matches(letters)) {
                return PlateValidation.invalid("The series is ${series.letters} letter${if (series.letters == 1) "" else "s"}.")
            }
            if (!letters.startsWith(series.fixed)) {
                return PlateValidation.invalid("${series.english} plates start with ${series.fixed}.")
            }
            if (!isDigitsOfLength(number, series.digits)) {
                return PlateValidation.invalid("The number is ${series.digits} digits.")
            }
            return PlateValidation.valid
        }
    }
}

/** Judges a `ColombiaPlates.police` value: two digits, then four. */
class ColombiaPoliceValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry) =
        if (isDigitsOfLength(entry.group("unit"), 2) && isDigitsOfLength(entry.group("number"), 4)) PlateValidation.valid
        else PlateValidation.invalid(REASON)

    companion object {
        const val REASON = "The number is two digits and four digits."
    }
}

/** Judges a `ColombiaPlates.diplomatic` value: a type letter, the mission's two-letter country initials, three digits. */
class ColombiaDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!typeLetter.matches(entry.group("type")) || !countryInitials.matches(entry.group("country"))) {
            return PlateValidation.invalid(REASON_LETTERS)
        }
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "A type letter and two country initials."
        const val REASON_NUMBER = "The number is three digits."
    }
}

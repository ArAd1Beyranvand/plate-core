package plates.countries.honduras

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isLetters

private val series = Regex("^[A-Z]{2}$")

/** Judges a 2018 plate: a class letter, two series letters and four digits (`HAB 0123`). Reports, never bars a keystroke. */
class HondurasValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isLetters(entry.group("class"), 1)) return PlateValidation.invalid(REASON_CLASS)
        if (!series.matches(entry.group("series"))) return PlateValidation.invalid(REASON_SERIES)
        if (!isDigitsOfLength(entry.group("serial"), 4)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_CLASS = "The class is one letter."
        const val REASON_SERIES = "The series is two letters."
        const val REASON_SERIAL = "The number is four digits."
    }
}

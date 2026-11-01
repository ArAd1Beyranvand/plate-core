package plates.countries.somalia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

private val series = Regex("^[A-Z]{2}$")
private val number = Regex("^[0-9]{4}$")

/** Judges a `SomaliaPlates` value, two letters and four digits (`AD 4657`). Reports, never bars a keystroke. */
class SomaliaPlateValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!series.matches(entry.group("series"))) return PlateValidation.invalid(REASON_SERIES)
        if (!number.matches(entry.group("number"))) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_SERIES = "The series is two letters."
        const val REASON_NUMBER = "The number is four digits."
    }
}

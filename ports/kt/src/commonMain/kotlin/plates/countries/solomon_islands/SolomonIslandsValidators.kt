package plates.countries.solomon_islands

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Judges a `SolomonIslandsPlates.private` value: two letters and four digits
 * (`MA 5021`). Reports, never bars. */
class SolomonIslandsValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) =
        if (!SERIES.matches(entry.group("series")!!)) PlateValidation.invalid(REASON_SERIES)
        else if (!isDigitsOfLength(entry.group("serial"), 4)) PlateValidation.invalid(REASON_SERIAL)
        else PlateValidation.valid

    companion object {
        const val REASON_SERIES = "The series is two letters."
        const val REASON_SERIAL = "The serial is four digits."
        val SERIES = Regex("^[A-Z]{2}$")
    }
}

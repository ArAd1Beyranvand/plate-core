package plates.countries.samoa

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

/** Judges a Samoan plate by its `serial` field: one to four digits. Reports, never bars a keystroke. */
class SamoaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val serial = entry.group("serial")
        if (serial.isEmpty() || serial.length > 4 || !isDigits(serial)) return PlateValidation.invalid(REASON_SERIAL)
        val mark = if (entry.spec.textGroups.any { it.key == "mark" }) entry.group("mark") else ""
        if (mark.isNotEmpty() && !isDigitsOfLength(mark, 1)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_SERIAL = "The number is one to four digits."
    }
}

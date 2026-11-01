package plates.countries.marshall_islands

import plates.core.validators.*

/** Judges a Marshallese plate by its `serial` group: four digits on the Majuro Atoll plate, one to three on the 1972 plate (both fit one to four). Reports, never bars a keystroke. */
class MarshallIslandsValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val serial = entry.group("serial")
        if (!isDigits(serial) || serial.length > 4) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_SERIAL = "The number is one to four digits."
    }
}

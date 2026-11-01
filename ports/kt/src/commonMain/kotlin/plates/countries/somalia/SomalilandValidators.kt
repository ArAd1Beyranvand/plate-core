package plates.countries.somalia

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.restrictionVerdict

private val serial = Regex("^[A-E][0-9]{4}$")
private val old = Regex("^[A-Z][0-9]{1,3}$")
private val regionCodes = listOf("AW", "MJ", "SL", "SN", "SX", "TG")

/** Judges a 2018 plate: a class letter and four digits (`C1234`) and, on private plates, a division code. */
class SomalilandValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val groups = entry.spec.textGroups
        if (groups.isEmpty() || entry.group(groups.last().key!!).isEmpty()) return PlateValidation.valid
        if (groups.any { it.key == "letter" }) {
            if (!old.matches(entry.group("letter") + entry.group("number"))) {
                return PlateValidation.invalid("A letter and one to three digits.")
            }
            return PlateValidation.valid
        }
        if (!serial.matches(entry.group("serial"))) {
            return PlateValidation.invalid("A class letter A–E and four digits.")
        }
        if (groups.any { it.key == "region" } && entry.group("region") !in regionCodes) {
            return PlateValidation.invalid("Unknown division code.")
        }
        return PlateValidation.valid
    }
}

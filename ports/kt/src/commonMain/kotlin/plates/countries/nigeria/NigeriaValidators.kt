package plates.countries.nigeria

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters3 = Regex("^[A-Z]{3}$")
private val letters2 = Regex("^[A-Z]{2}$")

/**
 * Judges a 2011 plate: three letters, three digits, two letters (`GGE-123ZY`). Reports, never bars a keystroke.
 *
 * Plates of Kogi and Niger mix letters and digits in the first field and are not modelled.
 */
class NigeriaValidator : GatedPlateValidator() {
    override val gateGroup = "suffix"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters3.matches(entry.group("area"))) return PlateValidation.invalid(REASON_AREA)
        if (!isDigitsOfLength(entry.group("serial"), 3)) return PlateValidation.invalid(REASON_SERIAL)
        if (!letters2.matches(entry.group("suffix"))) return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_AREA = "The area code is three letters."
        const val REASON_SERIAL = "The number is three digits."
        const val REASON_SUFFIX = "The suffix is two letters."
    }
}

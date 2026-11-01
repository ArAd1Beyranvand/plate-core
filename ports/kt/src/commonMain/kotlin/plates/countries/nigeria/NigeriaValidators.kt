package plates.countries.nigeria

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isLetters

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.

/**
 * Judges a 2011 plate: three letters, three digits, two letters (`GGE-123ZY`). Reports, never bars a keystroke.
 *
 * Plates of Kogi and Niger mix letters and digits in the first field and are not modelled.
 */
class NigeriaValidator : GatedPlateValidator() {
    override val gateGroup = "suffix"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isLetters(entry.group("area"), 3)) return PlateValidation.invalid(REASON_AREA)
        if (!isDigitsOfLength(entry.group("serial"), 3)) return PlateValidation.invalid(REASON_SERIAL)
        if (!isLetters(entry.group("suffix"), 2)) return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_AREA = "The area code is three letters."
        const val REASON_SERIAL = "The number is three digits."
        const val REASON_SUFFIX = "The suffix is two letters."
    }
}

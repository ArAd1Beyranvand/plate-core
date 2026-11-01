package plates.countries.polynesia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII class, portable across JVM/JS/Wasm regex engines.
private val block = Regex("^[1-7]$")

/** Judges a `3◆203` value: a block digit 1 to 7, then three digits (leading zeros are printed; cancelled blocks were reissued from 000). Reports, never bars a keystroke. */
class NorfolkIslandValidator : GatedPlateValidator() {
    override val gateGroup = "block"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!block.matches(entry.group("block"))) return PlateValidation.invalid(REASON_BLOCK)
        if (!isDigitsOfLength(entry.group("serial"), 3)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_BLOCK = "The block is a digit from 1 to 7."
        const val REASON_SERIAL = "The number is three digits."
    }
}

package plates.countries.gambia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII class, portable across JVM/JS/Wasm regex engines.
private val letter = Regex("^[A-Z]$")

/** Judges `BJL 0123 A` field by field: `region`, `number` (4 digits) and `suffix` (1 letter). Reports, never bars a keystroke. */
class GambiaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("region") !in regions) return PlateValidation.invalid("The region code is not a known one.")
        if (!isDigitsOfLength(entry.group("number"), 4)) return PlateValidation.invalid("The number is 4 digits.")
        if (!letter.matches(entry.group("suffix"))) return PlateValidation.invalid("The suffix is 1 letter.")
        return PlateValidation.valid
    }

    companion object {
        /** Codes from 2019 and the 1994–2019 ones still in the street. */
        val regions = setOf(
            "BJL", "KM",
            "WCR", "NBR", "LRR", "CRR", "URR",
            "WD", "NBD", "LRD", "CRD", "URD",
        )
    }
}

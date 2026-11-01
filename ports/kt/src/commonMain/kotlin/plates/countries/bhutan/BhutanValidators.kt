package plates.countries.bhutan

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val area = Regex("^[1-5]$")
private val series = Regex("^[A-Z]$")
private val digits12 = Regex("^[0-9]{1,2}$")

/**
 * Judges a Bhutanese plate. Reports, never bars a keystroke.
 *
 * Every category keeps its type letters in the `type` group and its serial in `number`; the civil plates
 * (`BP-1-A1234`) also have `area` (1 to 5) and `series` (a letter). [types] are the type codes the category carries.
 */
class BhutanValidator(val types: List<String> = listOf("BP", "BT", "BG")) : GatedPlateValidator() {
    override val gateGroup = "type"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("type") !in types) return PlateValidation.invalid("The type is ${types.joinToString(" or ")}.")
        val keys = entry.spec.effectiveTextGroups.map { it.key }.toSet()
        if ("area" in keys && !area.matches(entry.group("area"))) return PlateValidation.invalid("The area code is 1 to 5.")
        if ("series" in keys && !series.matches(entry.group("series"))) {
            return PlateValidation.invalid("The series is one letter.")
        }
        if (!isDigitsOfLength(entry.group("number"), 4)) return PlateValidation.invalid("The number is 4 digits.")
        return PlateValidation.valid
    }

    companion object {
        /** Royal Bhutan Police: `RBP-2300`. */
        fun police() = BhutanValidator(listOf("RBP"))

        /** Royal Bodyguard: `RBG 8047`. */
        fun royalGuard() = BhutanValidator(listOf("RBG"))
    }
}

/** Judges a diplomatic plate: a country or organisation number (1 or 2 digits), "CD" and a serial (1 or 2 digits). */
class BhutanDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "country"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!digits12.matches(entry.group("country"))) return PlateValidation.invalid("The country number is 1 or 2 digits.")
        if (!digits12.matches(entry.group("serial"))) return PlateValidation.invalid("The serial is 1 or 2 digits.")
        return PlateValidation.valid
    }
}

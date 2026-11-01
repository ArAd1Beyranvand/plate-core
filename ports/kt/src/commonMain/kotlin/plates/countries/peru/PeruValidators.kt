package plates.countries.peru

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

private val alphanumeric = Regex("^[A-Z0-9]+$")
private val letters = Regex("^[A-Z]+$")

/** Judges a 2010 plate field by field: a register and a serial. Reports, never bars a keystroke. */
class PeruValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val id = entry.spec.id
        val special = id == "pe.special"
        val registerLength = if (id == "pe.regular") 3 else 2
        val serialLength = if (id == "pe.motorcycle") 4 else 3
        val register = entry.group("register")
        if (register.length != registerLength || !(if (special) letters else alphanumeric).matches(register)) {
            return PlateValidation.invalid(REASON_REGISTER)
        }
        if (!special && register.startsWith("E")) return PlateValidation.invalid(REASON_SPECIAL)
        if (!isDigitsOfLength(entry.group("serial"), serialLength)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_REGISTER = "The register is three letters or digits (AB1), two on a motorcycle, two letters on a special plate."
        const val REASON_SERIAL = "The number is three digits, four on a motorcycle."
        const val REASON_SPECIAL = "E marks the special series; a regular register does not start with it."
    }
}

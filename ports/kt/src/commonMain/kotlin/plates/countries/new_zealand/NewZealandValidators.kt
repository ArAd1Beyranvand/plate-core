package plates.countries.new_zealand

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters3 = Regex("^[A-Z]{3}$")
private val letters2 = Regex("^[A-Z]{2}$")
private val run = Regex("^[A-Z0-9]{1,6}$")

/** Judges a standard plate: three letters and three digits (`ABC 123`). Reports, never bars a keystroke. */
class NewZealandValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters3.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(entry.group("serial"), 3)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The letters are three capitals."
        const val REASON_SERIAL = "The number is three digits."
    }
}

/** Judges the older plate: two letters and four digits (`GG 9094`). */
class NewZealandLegacyValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters2.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(entry.group("serial"), 4)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The letters are two capitals."
        const val REASON_SERIAL = "The number is four digits."
    }
}

/** Judges a personalised plate: one to six letters and digits, one field. */
class NewZealandPersonalisedValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation =
        if (run.matches(entry.group("serial"))) PlateValidation.valid else PlateValidation.invalid(REASON_RUN)

    companion object {
        const val REASON_RUN = "A personalised plate is one to six letters or digits."
    }
}

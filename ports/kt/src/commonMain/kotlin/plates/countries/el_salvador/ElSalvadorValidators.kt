package plates.countries.el_salvador

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII class, portable across JVM/JS/Wasm regex engines.
private val letter = Regex("^[A-Z]$")

/** Judges a 1976 car plate: a class letter and four digits (`P-0000`). Reports, never bars a keystroke. */
class ElSalvadorValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letter.matches(entry.group("letter"))) return PlateValidation.invalid(REASON_LETTER)
        if (!isDigitsOfLength(entry.group("serial"), 4)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTER = "The class is one letter."
        const val REASON_SERIAL = "The number is four digits."
    }
}

/** Judges a 1976 motorcycle plate: a letter, one digit and three digits (`M-1-234`). */
class ElSalvadorMotorcycleValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letter.matches(entry.group("letter"))) return PlateValidation.invalid(REASON_LETTER)
        if (!isDigitsOfLength(entry.group("series"), 1)) return PlateValidation.invalid(REASON_SERIES)
        if (!isDigitsOfLength(entry.group("serial"), 3)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTER = "The class is one letter."
        const val REASON_SERIES = "The series is one digit."
        const val REASON_SERIAL = "The number is three digits."
    }
}

package plates.countries.mozambique

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val provinceCodes = listOf("CA", "GZ", "IB", "MC", "MP", "MN", "NP", "NS", "SF", "TT", "ZB")

/** Judges a 2011-series plate (`ABC 123 MC`): three letters, three digits and a province code. Reports, never bars a keystroke. */
class MozambiqueValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_NUMBER)
        if (entry.group("province") !in provinceCodes) return PlateValidation.invalid(REASON_PROVINCE)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The series is three letters."
        const val REASON_NUMBER = "The number is three digits."
        const val REASON_PROVINCE = "The province is CA, GZ, IB, MC, MP, MN, NP, NS, SF, TT or ZB."
        private val letters = Regex("^[A-Z]{3}$")
    }
}

/** Judges a pre-2011 plate (`MLY 01-81`): an `M`, two district letters and two pairs of digits. */
class MozambiqueLegacyValidator : GatedPlateValidator() {
    override val gateGroup = "first"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(entry.group("first"), 2) || !isDigitsOfLength(entry.group("second"), 2)) {
            return PlateValidation.invalid(REASON_DIGITS)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The series is M and two district letters."
        const val REASON_DIGITS = "The number is two pairs of digits."
        private val letters = Regex("^M[A-Z]{2}$")
    }
}

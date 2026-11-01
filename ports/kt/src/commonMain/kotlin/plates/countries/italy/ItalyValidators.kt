package plates.countries.italy

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters = Regex("^[A-HJ-NP-TV-Z]{2}$")
private val code = Regex("^[A-Z]{2}$")

/** Judges an Italian plate: `AA 000 AA` on a car, two letters and five digits on a motorcycle; no I, O, Q, U. Reports, never bars a keystroke. */
class ItalyValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters.matches(entry.group("prefix"))) return PlateValidation.invalid(REASON_PREFIX)
        val suffix = entry.group("suffix")
        if (!isDigitsOfLength(entry.group("number"), if (suffix.isEmpty()) 5 else 3)) return PlateValidation.invalid(REASON_NUMBER)
        if (suffix.isNotEmpty() && !letters.matches(suffix)) return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is two letters (no I, O, Q, U)."
        const val REASON_NUMBER = "The number is three digits, or five on a motorcycle."
        const val REASON_SUFFIX = "The suffix is two letters (no I, O, Q, U)."
    }
}

/** Judges a diplomatic, consular or United Nations plate; `Q` and `V` are not used on consular plates. */
class ItalyDiplomaticValidator(val digits: Int = 4, val consular: Boolean = false) : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("number"), digits)) return PlateValidation.invalid(REASON_NUMBER)
        val c = entry.group("code")
        if (!code.matches(c)) return PlateValidation.invalid(REASON_CODE)
        if (consular && ('Q' in c || 'V' in c)) return PlateValidation.invalid(REASON_CONSULAR)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is three or four digits."
        const val REASON_CODE = "The country code is two letters."
        const val REASON_CONSULAR = "Consular codes leave out Q and V."
    }
}

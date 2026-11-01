package plates.countries.comoros

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII class, portable across JVM/JS/Wasm regex engines.
private val letters = Regex("^[A-HJ-NP-TV-Z]{2}$")

/** Judges a Mayotte SIV plate: two letters, three digits (001-999) and two letters, with the departement 976 on the right. */
class MayotteValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val prefix = entry.group("prefix")
        if (!letters.matches(prefix) || prefix == "SS") return PlateValidation.invalid(REASON_PREFIX)
        val number = entry.group("number")
        if (!isDigitsOfLength(number, 3) || number == "000") return PlateValidation.invalid(REASON_NUMBER)
        val suffix = entry.group("suffix")
        if (!letters.matches(suffix) || suffix == "SS") return PlateValidation.invalid(REASON_SUFFIX)
        val code = entry.group("department")
        if (code.isNotEmpty() && code != DEPARTMENT) return PlateValidation.invalid(REASON_DEPARTMENT)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is two letters (no I, O, U or SS)."
        const val REASON_NUMBER = "The number is three digits, 001–999."
        const val REASON_SUFFIX = "The suffix is two letters (no I, O, U or SS)."
        const val REASON_DEPARTMENT = "The département code is 976."
        const val DEPARTMENT = "976"
    }
}

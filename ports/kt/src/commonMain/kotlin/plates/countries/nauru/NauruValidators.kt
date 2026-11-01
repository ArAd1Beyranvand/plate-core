package plates.countries.nauru

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isLetters

// H9: explicit ASCII class, portable across JVM/JS/Wasm regex engines.

/**
 * Judges a Nauruan plate by its groups: `letters` (three) with `serial` (three digits) on the 2015 plate, `serial` alone
 * (four digits) on the 1975 plate, `prefix` (one digit) with `serial` (three) on the 1970 plate. Reports, never bars a keystroke.
 */
class NauruValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val letters = entry.group("letters")
        val prefix = entry.group("prefix")
        val hasLetters = letters.isNotEmpty()
        val hasPrefix = prefix.isNotEmpty()
        if (hasLetters && !isLetters(letters, 3)) return PlateValidation.invalid(REASON_LETTERS)
        if (hasPrefix && !isDigitsOfLength(prefix, 1)) return PlateValidation.invalid(REASON_PREFIX)
        val digits = if (hasLetters || hasPrefix) 3 else 4
        if (!isDigitsOfLength(entry.group("serial"), digits)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The register is three letters."
        const val REASON_PREFIX = "The prefix is one digit."
        const val REASON_SERIAL = "The number has the wrong digit count."
    }
}

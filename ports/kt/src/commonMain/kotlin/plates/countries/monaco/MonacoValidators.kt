package plates.countries.monaco

import plates.core.validators.*

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val serialRe = Regex("^(?:[A-Z][0-9]{3}|[0-9]{4}|[0-9]{3}[A-Z])$")
private val lettersRe = Regex("^[A-Z]{2}$")
private val digitsRe = Regex("^[0-9]{2}$")

/**
 * Judges a Monaco plate. A car's `serial` is one letter and three digits, four digits, or three digits and one
 * letter; a motorcycle's is two `letters` and two `digits`. Reports, never bars a keystroke.
 */
class MonacoValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val serial = entry.group("serial")
        if (serial.isNotEmpty()) {
            return if (serialRe.matches(serial)) PlateValidation.valid else PlateValidation.invalid(REASON_SERIAL)
        }
        val digits = entry.group("digits")
        if (digits.isEmpty()) return PlateValidation.valid
        if (!lettersRe.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        return if (digitsRe.matches(digits)) PlateValidation.valid else PlateValidation.invalid(REASON_DIGITS)
    }

    companion object {
        const val REASON_SERIAL = "The serial is four digits, a letter and three digits, or three digits and a letter."
        const val REASON_LETTERS = "The motorcycle prefix is two letters."
        const val REASON_DIGITS = "The motorcycle number is two digits."
    }
}

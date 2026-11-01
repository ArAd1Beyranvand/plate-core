package plates.countries.moldova

import plates.core.validators.*

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val month = Regex("^(0[1-9]|1[0-2])$")
private val year = Regex("^[0-9]{2}$")

private fun lettersDigits(letters: Int, digits: Int) =
    linkedMapOf("letters" to Regex("^[A-Z]{$letters}$"), "digits" to Regex("^[0-9]{$digits}$"))

private val formats: Map<String, Map<String, Regex>> = mapOf(
    "md.private" to lettersDigits(3, 3),
    "md.state" to lettersDigits(3, 3),
    "md.interior" to lettersDigits(3, 4),
    "md.armedForces" to lettersDigits(2, 4),
    "md.president" to lettersDigits(2, 4),
    "md.protection" to lettersDigits(2, 3),
    "md.foreign" to (lettersDigits(1, 4) + mapOf("month" to month, "year" to year)),
    "md.exported" to (lettersDigits(1, 3) + mapOf("suffix" to Regex("^[A-Z]$"), "month" to month, "year" to year)),
    "md.resident" to lettersDigits(1, 4),
    "md.diplomatic" to (lettersDigits(2, 3) + mapOf("suffix" to Regex("^[A-Z]{2}$"))),
)

/**
 * Judges a Moldovan plate field by field. Reports, never bars a keystroke.
 *
 * Private and state plates are three letters and three digits, the Ministry of Internal Affairs three and four,
 * the armed forces and president two and four, the protection service two and three, the red plates a letter and
 * four digits (exported: three and a letter) with a month 01-12 and a two-digit year, and the diplomatic plate
 * two letters, three digits and two letters.
 */
class MoldovaValidator : GatedPlateValidator() {
    override val gateGroup = "digits"

    override fun judge(entry: PlateEntry): PlateValidation {
        val format = formats[entry.spec.id] ?: return PlateValidation.valid
        for ((key, re) in format) {
            if (!re.matches(entry.group(key))) return PlateValidation.invalid(REASON)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON = "The plate does not match its format."
    }
}

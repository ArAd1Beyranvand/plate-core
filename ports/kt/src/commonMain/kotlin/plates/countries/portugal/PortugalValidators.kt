package plates.countries.portugal

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength
import plates.core.validators.restrictionVerdict

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters = Regex("^[A-Z]{2}$")
private val letter = Regex("^[A-Z]$")
private val mixed = Regex("^[A-Z][0-9]$")

private fun pair(v: String) = letters.matches(v) || isDigitsOfLength(v, 2)

/**
 * Judges a Portuguese plate by the groups its spec carries: three fields of two characters in one of the series' orders
 * (`AA 00 AA`, `00 AA 00`, `00 00 AA`, `AA 00 00`, or `A1 00 AA` on US Forces plates), a ribbon `year` and `month` (01-12),
 * a GNR plate, a trailer plate or a diplomatic plate. Reports, never bars a keystroke.
 */
class PortugalValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }

        val embassy = entry.group("embassy")
        if (embassy.isNotEmpty()) {
            return if (embassy.length <= 3 && isDigits(embassy) && entry.group("code") == "CD" &&
                isDigitsOfLength(entry.group("number"), 3)
            ) PlateValidation.valid else PlateValidation.invalid(REASON_DIPLOMATIC)
        }
        val district = entry.group("district")
        if (district.isNotEmpty()) {
            val number = entry.group("number")
            return if (letters.matches(district.padEnd(2, 'A')) && isDigits(number) && number.length <= 6) {
                PlateValidation.valid
            } else PlateValidation.invalid(REASON_TRAILER)
        }
        val gnr = entry.group("letter")
        if (gnr.isNotEmpty()) {
            return if (letter.matches(gnr) && isDigitsOfLength(entry.group("number"), 4)) PlateValidation.valid
            else PlateValidation.invalid(REASON_GNR)
        }

        val first = entry.group("first")
        if (first.isEmpty()) return PlateValidation.valid
        if (!(pair(first) || mixed.matches(first)) || !pair(entry.group("second")) || !pair(entry.group("third"))) {
            return PlateValidation.invalid(REASON_SHAPE)
        }
        val year = entry.group("year")
        val month = entry.group("month")
        if (year.isNotEmpty() || month.isNotEmpty()) {
            val m = month.toIntOrNull()
            if (!isDigitsOfLength(year, 2) || !isDigitsOfLength(month, 2) || m == null || m < 1 || m > 12) {
                return PlateValidation.invalid(REASON_DATE)
            }
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_SHAPE = "A plate is three fields of two characters: letters AA, digits 00."
        const val REASON_DATE = "The ribbon is a two-digit year and month."
        const val REASON_GNR = "A GNR plate is one letter and four digits."
        const val REASON_TRAILER = "A trailer plate is one or two district letters and up to six digits."
        const val REASON_DIPLOMATIC = "A diplomatic plate is one to three digits, CD and three digits."
    }
}

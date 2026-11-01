package plates.countries.cape_verde

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.restrictionVerdict

// H9: explicit ASCII classes.
private val shape = mapOf(
    "series" to (Regex("^[A-Z]{2}$") to "The island code is 2 letters."),
    "number" to (Regex("^[0-9]{2}$") to "The number is 2 digits."),
    "letters" to (Regex("^[A-Z]{2}$") to "The closing series is 2 letters."),
    "suffix" to (Regex("^[A-Z]$") to "The suffix is 1 letter."),
    "first" to (Regex("^[0-9]{2}$") to "The first number is 2 digits."),
    "second" to (Regex("^[0-9]{2}$") to "The second number is 2 digits."),
    "country" to (Regex("^[0-9]{2}$") to "The country code is 2 digits."),
    "serial" to (Regex("^[0-9]{3}$") to "The serial is 3 digits."),
)

/** Judges a plate by whichever registers its spec has. Quiet until the last register has something in it. */
class CapeVerdeValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val groups = entry.spec.textGroups
        if (groups.isEmpty() || entry.group(groups.last().key!!).isEmpty()) return PlateValidation.valid
        for (g in groups) {
            val rule = shape[g.key] ?: continue
            if (!rule.first.matches(entry.group(g.key!!))) return PlateValidation.invalid(rule.second)
        }
        if (entry.spec.id == "cv.regular" && entry.group("series") !in islands) {
            return PlateValidation.invalid("Unknown island code.")
        }
        return PlateValidation.valid
    }

    companion object {
        val islands = setOf("BR", "BV", "FG", "MA", "SA", "SL", "SN", "ST", "SV")
    }
}

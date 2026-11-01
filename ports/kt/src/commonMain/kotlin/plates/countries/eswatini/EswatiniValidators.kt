package plates.countries.eswatini

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.isLetters
import plates.core.validators.restrictionVerdict

private val series = Regex("^[A-Z]SD$")
private val number = Regex("^[0-9]{3}$")

/** Judges an Eswatini plate field by field: `JSD 884 BM`. Quiet until the last field has content. Reports, never bars a keystroke. */
class EswatiniValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val suffix = entry.group("suffix")
        if (suffix.isEmpty()) return PlateValidation.valid
        if (!series.matches(entry.group("series"))) return PlateValidation.invalid("The series is a letter then SD.")
        if (!number.matches(entry.group("number"))) return PlateValidation.invalid("The number is 3 digits.")
        if (!isLetters(suffix, 2)) return PlateValidation.invalid("The suffix is 2 letters.")
        if (suffix[1].toString() !in regions) return PlateValidation.invalid("Unknown region letter.")
        return PlateValidation.valid
    }

    companion object {
        /** Region initials: Hhohho, Lubombo, Manzini, Shiselweni. */
        val regions = listOf("H", "L", "M", "S")
    }
}

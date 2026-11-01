package plates.countries.ivory_coast

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.isDigitsOfLength
import plates.core.validators.restrictionVerdict

private val letters2 = Regex("^[A-Z]{2}$")

/** Judges an Ivory Coast plate field by field; quiet until the last field has something in it. Reports, never bars a keystroke. */
class IvoryCoastValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val groups = entry.spec.textGroups
        if (groups.isEmpty() || entry.group(groups.last().key!!).isEmpty()) return PlateValidation.valid
        val id = entry.spec.id
        for (g in groups) {
            val value = entry.group(g.key!!)
            val ok = when (g.key) {
                "number" -> when (id) {
                    "ci.private" -> isDigitsOfLength(value, 4) to "The number is 4 digits."
                    "ci.military" -> isDigitsOfLength(value, 5) to "The number is 5 digits."
                    else -> isDigitsOfLength(value, 3) to "The number is 3 digits."
                }
                "series" -> letters2.matches(value) to "The series is 2 letters."
                "region" -> isDigitsOfLength(value, 2) to "The region code is 2 digits."
                else -> continue
            }
            if (!ok.first) return PlateValidation.invalid(ok.second)
        }
        return PlateValidation.valid
    }
}

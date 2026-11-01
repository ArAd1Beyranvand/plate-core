package plates.countries.south_africa

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.restrictionVerdict

private val letters3 = Regex("^[A-Z]{3}$")
private val letters2 = Regex("^[A-Z]{2}$")
private val digits1to3 = Regex("^[0-9]{1,3}$")
private val digits2 = Regex("^[0-9]{2}$")

/** Judges a South African plate field by field: `ABC 123 EC` and `AB 12 CD GP`. Quiet until the last field has something in it. */
class SouthAfricaValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val groups = entry.spec.textGroups
        if (groups.isEmpty() || entry.group(groups.last().key!!).isEmpty()) return PlateValidation.valid
        val modern = entry.spec.id == "za.modern"
        for (g in groups) {
            val value = entry.group(g.key!!)
            val rule = when (g.key) {
                "series" -> if (modern) letters2 to "The series is 2 letters." else letters3 to "The series is 3 letters."
                "number" -> if (modern) digits2 to "The number is 2 digits." else digits1to3 to "The number is 1 to 3 digits."
                "letters" -> letters2 to "The closing letters are 2 letters."
                else -> null
            }
            if (rule != null && !rule.first.matches(value)) return PlateValidation.invalid(rule.second)
        }
        if (entry.group("province") !in provinces) return PlateValidation.invalid("Unknown province suffix.")
        return PlateValidation.valid
    }

    companion object {
        /** Province suffixes; `G`, `M`, `B` mark government, defence-force and police vehicles. */
        val provinces = setOf("EC", "FS", "GP", "L", "MP", "NC", "NW", "WP", "ZN", "G", "M", "B")
    }
}

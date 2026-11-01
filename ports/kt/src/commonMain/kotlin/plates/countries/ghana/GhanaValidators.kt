package plates.countries.ghana

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.restrictionVerdict

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val numberRe = Regex("^[0-9]{1,4}$")
private val yearRe = Regex("^[0-9]{2}$")
private val classRe = Regex("^M$")

/** Judges a Ghanaian plate field by field. Quiet until the last field has something in it. Reports, never bars a keystroke. */
class GhanaValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val groups = entry.spec.textGroups
        if (groups.isEmpty() || entry.group(groups.last().key!!).isEmpty()) return PlateValidation.valid
        for (g in groups) {
            val value = entry.group(g.key!!)
            val rule = when (g.key) {
                "number" -> numberRe to "The number is 1 to 4 digits."
                "year" -> yearRe to "The year is 2 digits."
                "class" -> classRe to "A motorcycle plate starts with M."
                else -> null
            }
            if (rule != null && !rule.first.matches(value)) return PlateValidation.invalid(rule.second)
        }
        if (entry.group("region") !in regions) return PlateValidation.invalid("Unknown region code.")
        return PlateValidation.valid
    }

    companion object {
        /** Region codes from the article, the services' own and the Free Zones Board's. */
        val regions = setOf(
            "AC", "AE", "AK", "AP", "AS", "AW",
            "BA", "BR", "BW", "BT", "CR",
            "EN", "ER", "ES",
            "GB", "GC", "GE", "GG", "GH", "GL", "GM", "GN", "GT", "GS", "GW", "GX", "GY",
            "NR", "UE", "UW", "VA", "VD", "VR", "WR", "WT",
            "GA", "GP", "FS", "PS",
        )
    }
}

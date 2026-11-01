package plates.countries.senegal

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.restrictionVerdict

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters2 = Regex("^[A-Z]{2}$")
private val letters1or2 = Regex("^[A-Z]{1,2}$")
private val digits2 = Regex("^[0-9]{2}$")
private val digits3 = Regex("^[0-9]{3}$")
private val digits4 = Regex("^[0-9]{4}$")

/** Judges a Senegalese plate field by field: the 1989-2019 `DK-1234-AB`, the current `AA-123-BC [DK / 01]`. Quiet until the last field has something in it. Reports, never bars a keystroke. */
class SenegalValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val groups = entry.spec.textGroups
        if (groups.isEmpty() || entry.group(groups.last().key!!).isEmpty()) return PlateValidation.valid
        val old = entry.spec.id == "sn.old"
        for (g in groups) {
            val value = entry.group(g.key!!)
            val rule: Pair<Regex, String>? = when {
                g.key == "number" && old -> digits4 to "The number is 4 digits."
                g.key == "number" -> digits3 to "The number is 3 digits."
                g.key == "letters" && old -> letters1or2 to "The closing series is 1 or 2 letters."
                g.key == "letters" -> letters2 to "The closing series is 2 letters."
                g.key == "series" -> letters2 to "The series is 2 letters."
                g.key == "department" -> digits2 to "The department is 2 digits."
                else -> null
            }
            if (rule != null && !rule.first.matches(value)) return PlateValidation.invalid(rule.second)
        }
        if (entry.group("region") !in regions) return PlateValidation.invalid("Unknown regional code.")
        return PlateValidation.valid
    }

    companion object {
        /** Dakar, Diourbel, Fatick, Kaffrine, Kaolack, Kedougou, Kolda, Louga, Matam, Saint-Louis, Sedhiou, Tambacounda, Thies, Ziguinchor. */
        val regions = setOf("DK", "DB", "FK", "KA", "KL", "KE", "KD", "LG", "MT", "SL", "SE", "TC", "TH", "ZG")
    }
}

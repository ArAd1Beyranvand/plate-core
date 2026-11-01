package plates.countries.india

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator

// Inlined from plate_alphabet's IndiaAlphabets: only the keys are judged.
private val states = setOf(
    "AN", "AP", "AR", "AS", "BR", "CG", "CH", "DD", "DL", "GA", "GJ", "HP", "HR", "JH", "JK", "KA", "KL", "LA",
    "LD", "MH", "ML", "MN", "MP", "MZ", "NL", "OD", "PB", "PY", "RJ", "SK", "TG", "TN", "TR", "UK", "UP", "WB",
    "UA", "OR", "DN", "TS",
)
private val militaryClasses = setOf("A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "P", "Q", "R", "X")
private val tradeCategories = setOf("A", "B", "C", "D", "E", "F", "G", "H", "I", "J")
private val missions = setOf("CD", "CC", "UN")

/** Judges any India plate by the groups its spec has. Quiet until every field has reached its minimum length. */
class IndiaValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        val slots = entry.spec.slots
        if (entry.values.size < slots.size || !slots.withIndex().all { (i, s) -> s.isComplete(entry.values[i]) }) {
            return PlateValidation.valid
        }
        val keys = entry.spec.effectiveTextGroups.map { it.key }.toSet()
        fun g(key: String) = entry.group(key)

        if ("state" in keys && g("state") !in states) return PlateValidation.invalid(REASON_STATE)
        if ("rto" in keys && g("rto") == "00") return PlateValidation.invalid(REASON_RTO)
        if ("number" in keys && g("number").toIntOrNull() == 0) return PlateValidation.invalid(REASON_NUMBER)
        if ("date" in keys) {
            val month = g("date").substring(0, 2).toIntOrNull() ?: 0
            if (month < 1 || month > 12) return PlateValidation.invalid(REASON_MONTH)
        }
        if ("class" in keys && g("class") !in militaryClasses) return PlateValidation.invalid(REASON_CLASS)
        if ("type" in keys && g("type") !in missions) return PlateValidation.invalid(REASON_MISSION)
        if ("category" in keys && g("category") !in tradeCategories) return PlateValidation.invalid(REASON_CATEGORY)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_STATE = "Not a state or union-territory code."
        const val REASON_RTO = "RTO number 00 is not issued."
        const val REASON_NUMBER = "Number 0000 is not issued."
        const val REASON_MONTH = "The month is not 01–12."
        const val REASON_CLASS = "Not an armed-forces vehicle class."
        const val REASON_MISSION = "Mission type is CD, CC or UN."
        const val REASON_CATEGORY = "Trade category is A to J."
    }
}

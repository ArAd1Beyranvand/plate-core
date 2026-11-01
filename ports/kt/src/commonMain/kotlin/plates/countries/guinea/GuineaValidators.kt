package plates.countries.guinea

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

private class Rule(val key: String, val pattern: Regex, val reason: String)

/** Judges a Guinean plate field by field, for whichever groups the spec has. Reports, never bars a keystroke. */
class GuineaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val keys = entry.spec.textGroups.mapNotNull { it.key }.toSet()
        val legacy = "prefix" in keys
        val rules = listOf(
            Rule(
                "series",
                Regex(if (legacy) "^[A-Z]{1,2}$" else "^[A-Z]{2}$"),
                if (legacy) "The series is 1 or 2 letters." else "The series is 2 letters.",
            ),
            Rule("number", Regex("^[0-9]{4}$"), "The number is 4 digits."),
            Rule("prefix", Regex("^[A-Z]{2}$"), "The region code is 2 letters (RC is Conakry)."),
            Rule("region", Regex("^0[1-8]$"), "The region code is 01 to 08."),
            Rule("suffix", Regex("^[A-Z]$"), "The suffix is 1 letter."),
        )
        for (rule in rules) {
            if (rule.key !in keys) continue
            if (!rule.pattern.matches(entry.group(rule.key))) return PlateValidation.invalid(rule.reason)
        }
        return PlateValidation.valid
    }
}

package plates.countries.burkina_faso

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** (group, digits rather than letters, length). */
typealias Rule = Triple<String, Boolean, Int>

/**
 * Judges a Burkinabè plate against its category's format. Reports, never bars a keystroke.
 *
 * - private: `12 AB 1234`; commercial: `12 A 1234`; police: `PN 1234`; gendarmerie: `1 2345 EMGN`.
 *
 * With no [rules] the category is taken from the spec id (`bf.private`, `bf.commercial`, ...).
 */
class BurkinaFasoValidator(private val rules: List<Rule>?) : GatedPlateValidator() {
    constructor() : this(null)

    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val chosen = rules ?: byCategory.entries.firstOrNull { entry.spec.id.endsWith(it.key) }?.value ?: private
        for ((group, digits, length) in chosen) {
            val value = entry.group(group)
            val ok = if (digits) isDigitsOfLength(value, length)
            else value.length == length && value.all { it in 'A'..'Z' }
            if (!ok) {
                return PlateValidation.invalid(
                    "The $group is $length ${if (digits) "digit" else "letter"}${if (length == 1) "" else "s"}.",
                )
            }
        }
        return PlateValidation.valid
    }

    companion object {
        val private = listOf(Rule("region", true, 2), Rule("letters", false, 2), Rule("serial", true, 4))
        val commercial = listOf(Rule("region", true, 2), Rule("letter", false, 1), Rule("serial", true, 4))
        val police = listOf(Rule("service", false, 2), Rule("serial", true, 4))
        val gendarmerie = listOf(Rule("unit", true, 1), Rule("serial", true, 4), Rule("corps", false, 4))

        private val byCategory = mapOf(
            "commercial" to commercial, "police" to police, "gendarmerie" to gendarmerie, "private" to private,
        )
    }
}

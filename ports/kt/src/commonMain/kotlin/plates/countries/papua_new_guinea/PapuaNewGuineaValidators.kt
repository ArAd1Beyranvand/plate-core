package plates.countries.papua_new_guinea

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

/** Judges `ABC 123` field by field: `lead` (letters) and `number` (digits). Each category has its own lengths and fixed prefix. */
class PapuaNewGuineaValidator(
    val leadMin: Int = 3,
    val leadMax: Int = 3,
    val numberMin: Int = 3,
    val numberMax: Int = 3,
    val leadStartsWith: String? = null,
) : GatedPlateValidator() {
    override val gateGroup = "number"

    private val leadRe = Regex("^[A-Z]{$leadMin,$leadMax}$")
    private val numberRe = Regex("^[0-9]{$numberMin,$numberMax}$")

    override fun judge(entry: PlateEntry): PlateValidation {
        val lead = entry.group("lead")
        if (!leadRe.matches(lead)) {
            return PlateValidation.invalid(
                if (leadMin == leadMax) "The letters are $leadMin." else "The letters are $leadMin to $leadMax.",
            )
        }
        val prefix = leadStartsWith
        if (prefix != null && !lead.startsWith(prefix)) return PlateValidation.invalid("The letters start with $prefix.")
        if (!numberRe.matches(entry.group("number"))) {
            return PlateValidation.invalid(
                if (numberMin == numberMax) "The number is $numberMin digits." else "The number is $numberMin to $numberMax digits.",
            )
        }
        return PlateValidation.valid
    }
}

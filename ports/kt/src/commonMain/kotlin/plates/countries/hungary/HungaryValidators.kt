package plates.countries.hungary

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

private val letter = Regex("^[A-Z]$")
private val two = Regex("^[A-Z]{2}$")
private val three = Regex("^[A-Z]{3}$")
private fun digits(n: Int) = Regex("^[0-9]{$n}$")

private val pairs = mapOf("a" to two, "b" to digits(2), "c" to digits(2))
private val letterDigitsYear = mapOf("a" to letter, "b" to digits(5), "c" to digits(2))

private val formats = mapOf(
    "hu.private" to mapOf("a" to two, "b" to two, "c" to digits(3)),
    "hu.diplomatic" to pairs,
    "hu.staff" to pairs,
    "hu.agricultural" to mapOf("a" to letter, "b" to digits(6)),
    "hu.export" to letterDigitsYear,
    "hu.trial" to letterDigitsYear,
    "hu.slow" to mapOf("a" to three, "b" to digits(3)),
)

/** Judges a Hungarian plate field by field, `a`, `b`, `c`. Reports, never bars a keystroke. */
class HungaryValidator : GatedPlateValidator() {
    override val gateGroup = "a"

    override fun judge(entry: PlateEntry): PlateValidation {
        val format = formats[entry.spec.id] ?: return PlateValidation.valid
        for ((key, pattern) in format) {
            if (!pattern.matches(entry.group(key))) return PlateValidation.invalid(REASON)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON = "The plate does not match its format."
    }
}

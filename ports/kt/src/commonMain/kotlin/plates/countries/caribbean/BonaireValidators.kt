package plates.countries.caribbean

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val prefix = Regex("^[A-Z]{1,2}$")

/** Judges a `bonaire` or `blue` value: a one- or two-letter type prefix and three to five digits. */
class BonaireValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!prefix.matches(entry.group("prefix"))) return PlateValidation.invalid(REASON_PREFIX)
        val number = entry.group("number")
        if (number.length < 3 || number.length > 5 || !isDigits(number)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is one or two letters."
        const val REASON_NUMBER = "The number is three to five digits."
    }
}

/** Judges a St. Eustatius or Saba value: the island letter and up to four digits. */
class BonaireIslandValidator(val island: String, val minDigits: Int = 1) : GatedPlateValidator() {
    override val gateGroup = "number"

    val reasonIsland get() = "The prefix is $island."

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("prefix") != island) return PlateValidation.invalid(reasonIsland)
        val number = entry.group("number")
        if (number.length < minDigits || number.length > 4 || !isDigits(number)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is up to four digits."
    }
}

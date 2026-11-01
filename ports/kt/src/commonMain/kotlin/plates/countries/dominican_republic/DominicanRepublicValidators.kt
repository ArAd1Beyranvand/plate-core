package plates.countries.dominican_republic

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isLetters

private val letter = Regex("^[A-Z]$")

private fun verdict(ok: Boolean, reason: String) = if (ok) PlateValidation.valid else PlateValidation.invalid(reason)

/** Judges two fields of three digits (`953-147`). */
class DominicanRepublicValidator : GatedPlateValidator() {
    override val gateGroup = "last"

    override fun judge(entry: PlateEntry) =
        verdict(isDigitsOfLength(entry.group("first"), 3) && isDigitsOfLength(entry.group("last"), 3), REASON)

    companion object {
        const val REASON = "A plate is two fields of three digits."
    }
}

/** Judges a letter, two digits and four digits (`P06-2686`). */
class DominicanRepublicLetteredValidator : GatedPlateValidator() {
    override val gateGroup = "tail"

    override fun judge(entry: PlateEntry) = verdict(
        letter.matches(entry.group("letter")) &&
            isDigitsOfLength(entry.group("head"), 2) &&
            isDigitsOfLength(entry.group("tail"), 4),
        REASON,
    )

    companion object {
        const val REASON = "A plate is a letter, two digits and four digits."
    }
}

/** Judges two letters and five digits (`EA 01320`). */
class DominicanRepublicExemptValidator : GatedPlateValidator() {
    override val gateGroup = "digits"

    override fun judge(entry: PlateEntry) = verdict(
        isLetters(entry.group("letters"), 2) && isDigitsOfLength(entry.group("digits"), 5),
        REASON,
    )

    companion object {
        const val REASON = "A plate is two letters and five digits."
    }
}

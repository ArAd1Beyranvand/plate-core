package plates.countries.cyprus

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII class, portable across JVM/JS/Wasm regex engines.
private val letters = Regex("^[A-Z]{3}$")

private fun between(v: String, min: Int, max: Int) = isDigits(v) && v.length in min..max

/** Judges a Cypriot plate by its groups; the spec id picks the rule. Reports, never bars a keystroke. */
class CyprusValidator : GatedPlateValidator() {
    override val gateGroup = "digits"

    override fun judge(entry: PlateEntry): PlateValidation {
        val digits = entry.group("digits")
        val (ok, reason) = when (entry.spec.id) {
            "cy.trailer" -> isDigitsOfLength(digits, 5) to REASON_TRAILER
            "cy.sba" -> isDigitsOfLength(digits, 2) to REASON_SBA
            "cy.diplomatic" ->
                (isDigitsOfLength(entry.group("code"), 2) && entry.group("class") in diplomaticClasses && between(digits, 1, 3)) to REASON_DIPLOMATIC
            "cy.dealer" -> (between(entry.group("dealer"), 1, 2) && between(digits, 1, 3)) to REASON_DEALER
            else -> (letters.matches(entry.group("letters")) && isDigitsOfLength(digits, 3)) to REASON_STANDARD
        }
        return if (ok) PlateValidation.valid else PlateValidation.invalid(reason)
    }

    companion object {
        const val REASON_STANDARD = "A plate is three letters, three digits."
        const val REASON_TRAILER = "A trailer plate is P and five digits."
        const val REASON_DIPLOMATIC = "A diplomatic plate is a two-digit code, CD, CC or AT, and 1-3 digits."
        const val REASON_SBA = "An SBA plate is SBAA and two digits."
        const val REASON_DEALER = "A dealer plate is the dealer number (1-2 digits) and a serial (1-3)."

        val diplomaticClasses = listOf("CD", "CC", "AT")
    }
}

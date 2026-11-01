package plates.countries.malta

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val personalised = Regex("^[A-Z0-9]{1,10}$")
private val letters3 = Regex("^[A-Z]{3}$")

/** Judges a Maltese plate by its groups. Reports, never bars a keystroke.
 *
 * A private plate is three letters and three digits (`WTO 110`); the bus
 * (`BUS 105`), trailer (`TR 1818`) and taxi (`TAXI 119 M`) plates have fixed
 * text and are judged on the digits and the island letter alone. A
 * personalised plate is one to ten letters and digits. */
class MaltaValidator : GatedPlateValidator() {
    override val gateGroup = "digits"

    override fun judge(entry: PlateEntry): PlateValidation {
        val digits = entry.group("digits")
        val letters = entry.group("letters")
        val island = entry.group("island")
        val text = entry.group("text")
        if (text.isNotEmpty()) {
            return if (personalised.matches(text)) PlateValidation.valid else PlateValidation.invalid(REASON_PERSONALISED)
        }
        if (island.isNotEmpty()) {
            return if (isDigitsOfLength(digits, 3) && (island == "M" || island == "G")) PlateValidation.valid
            else PlateValidation.invalid(REASON_TAXI)
        }
        if (letters.isNotEmpty()) {
            return if (isDigitsOfLength(digits, 3) && letters3.matches(letters)) PlateValidation.valid
            else PlateValidation.invalid(REASON_PRIVATE)
        }
        return if (isDigitsOfLength(digits, 3) || isDigitsOfLength(digits, 4)) PlateValidation.valid
        else PlateValidation.invalid(REASON_BUS)
    }

    companion object {
        const val REASON_PRIVATE = "A plate is three letters, three digits."
        const val REASON_BUS = "A bus plate is BUS and three digits."
        const val REASON_TRAILER = "A trailer plate is TR and four digits."
        const val REASON_TAXI = "A taxi plate is TAXI, three digits and M or G."
        const val REASON_PERSONALISED = "A personalised plate is one to ten letters or digits."
    }
}

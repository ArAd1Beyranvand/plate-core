package plates.countries.mauritius

import plates.core.validators.*

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters = Regex("^[A-Z]{2}$")

/** Judges a government plate (`GM 3345`): two letters and four digits. Reports, never bars a keystroke. */
class MauritiusValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(entry.group("serial"), 4)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The prefix is two letters."
        const val REASON_SERIAL = "The number is four digits."
    }
}

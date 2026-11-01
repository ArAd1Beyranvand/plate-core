package plates.countries.mauritania

import plates.core.validators.*

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val number = Regex("^[0-9]{4}$")
private val letters = Regex("^[A-Z]{2}$")

/** The two-digit region code that ends a plate (`MauritaniaRegions.byCode`). */
private val regionCodes = (0..12).map { it.toString().padStart(2, '0') }.toSet()

/** Judges a `MauritaniaPlates` value, `NNNN LL RR`. Reports, never bars a keystroke. */
class MauritaniaPlateValidator : GatedPlateValidator() {
    override val gateGroup = "region"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!number.matches(entry.group("number"))) return PlateValidation.invalid(REASON_NUMBER)
        if (!letters.matches(entry.group("letters"))) return PlateValidation.invalid(REASON_LETTERS)
        if (entry.group("region") !in regionCodes) return PlateValidation.invalid(REASON_REGION)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is four digits."
        const val REASON_LETTERS = "The series is two letters."
        const val REASON_REGION = "The region is 00 to 12."
    }
}

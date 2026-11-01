package plates.countries.caribbean

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

/**
 * Judges a Saba value: one prefix letter and a run of digits. The 2011 plate is `S 240` (three or four
 * digits), the 1978 plate `S-163` (up to three). Reports, never bars a keystroke.
 */
class SabaIslandValidator(val minDigits: Int = 3, val maxDigits: Int = 4) : GatedPlateValidator() {
    override val gateGroup = "number"

    val reasonNumber
        get() = if (minDigits == maxDigits) "The number is $maxDigits digits." else "The number is $minDigits to $maxDigits digits."

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!prefix.matches(entry.group("prefix"))) return PlateValidation.invalid(REASON_PREFIX)
        val number = entry.group("number")
        // Code units, safe because isDigits passes ASCII alone (H24).
        if (number.length < minDigits || number.length > maxDigits || !isDigits(number)) return PlateValidation.invalid(reasonNumber)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is S, R or D."

        // Portable syntax only: the engine differs per target (H9).
        private val prefix = Regex("[SRD]")

        /** The 1978 plate: `S-123`, one to three digits. */
        fun classic1978() = SabaIslandValidator(minDigits = 1, maxDigits = 3)
    }
}

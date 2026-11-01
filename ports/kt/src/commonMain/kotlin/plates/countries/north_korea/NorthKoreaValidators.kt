package plates.countries.north_korea

import plates.core.alphabet.AlphabetInput
import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

/** Checks completeness, and flags 4 as the leading class digit on regional plates: class prefixes run 1-7 and skip 4. */
class KPValidator(override val gateGroup: String = "number") : GatedPlateValidator() {
    override fun judge(entry: PlateEntry): PlateValidation {
        for ((i, slot) in entry.spec.slots.withIndex()) {
            val value = entry.values.getOrNull(i) ?: ""
            // A chosen value (the region) is one symbol, however many characters.
            val want = if (slot.alphabet.input == AlphabetInput.chosen) 1 else slot.length
            if (value.isEmpty() || (want > 1 && value.length != want)) {
                return PlateValidation.invalid(REASON_INCOMPLETE)
            }
        }
        if (entry.group("class").startsWith("4")) return PlateValidation.invalid(REASON_FOUR)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_INCOMPLETE = "Every position must be filled."
        const val REASON_FOUR = "Class codes never start with 4."
    }
}

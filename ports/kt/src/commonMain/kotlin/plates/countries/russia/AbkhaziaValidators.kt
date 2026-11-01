package plates.countries.russia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.alphabet.AlphabetInput

/** Judges a registration on any AbkhaziaPlates spec. Reports, never bars a keystroke. The diplomatic number is one digit after `CD`, three after `D` or `T` (assumed from Russia). */
class AbkhaziaValidator : GatedPlateValidator() {
    override val gateGroup = "series"

    override fun judge(entry: PlateEntry): PlateValidation {
        val spec = entry.spec
        for (i in spec.slots.indices) {
            val slot = spec.slots[i]
            val value = entry.group(spec.textGroups[i].key!!)
            val whole = slot.alphabet.input == AlphabetInput.chosen
            if (!slot.accepts(value) || !whole && (value.length < slot.minLength || value.length > slot.length)) {
                return PlateValidation.invalid(REASON_FIELD)
            }
        }
        if (spec.id == "ab.diplomatic") {
            val want = if (entry.group("status") == "CD") 1 else 3
            if (entry.group("number").length != want) return PlateValidation.invalid(REASON_NUMBER)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_FIELD = "A field has the wrong length or letters."
        const val REASON_NUMBER = "The diplomatic number is one digit after CD, three after D or T."
    }
}

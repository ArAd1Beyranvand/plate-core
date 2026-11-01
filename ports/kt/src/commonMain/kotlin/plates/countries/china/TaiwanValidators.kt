package plates.countries.china

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

/** 2014 series: three letters (no I, O) then four digits. */
open class TaiwanValidator : GatedPlateValidator() {
    override val gateGroup = "digits"

    override fun judge(entry: PlateEntry): PlateValidation {
        val spec = entry.spec
        for ((i, slot) in spec.slots.withIndex()) {
            val v = entry.group(spec.textGroups[i].key!!)
            if (!slot.accepts(v) || v.length != slot.length) return PlateValidation.invalid(REASON_FIELD)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_FIELD = "Three letters and four digits."
    }
}

/** 1992 series: two letters then four digits; the slot lengths already say so. */
class TaiwanLegacyValidator : TaiwanValidator()

/** Embassy and foreign-affairs plates: the glyph then [minDigits]-[maxDigits] digits. */
class TaiwanProtocolValidator(val minDigits: Int = 2, val maxDigits: Int = 3) : GatedPlateValidator() {
    override val gateGroup = "digits"

    override fun judge(entry: PlateEntry): PlateValidation {
        val v = entry.group("digits")
        if (!entry.spec.slots.first().accepts(v) || v.length < minDigits || v.length > maxDigits) {
            return PlateValidation.invalid(REASON_DIGITS)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_DIGITS = "The number has the wrong length."
    }
}

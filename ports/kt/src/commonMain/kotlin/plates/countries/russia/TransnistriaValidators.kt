package plates.countries.russia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

// Keys of TransnistriaRegions.names.
private val transnistriaRegions = setOf("A", "B", "E", "K", "P", "C", "T", "H")

/** Judges a Transnistrian registration: each field the right length and alphabet, and the region letter one of the region codes. Reports, never bars a keystroke. */
class TransnistriaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val spec = entry.spec
        for (i in spec.slots.indices) {
            val slot = spec.slots[i]
            val value = entry.group(spec.textGroups[i].key!!)
            if (!slot.accepts(value) || value.length < slot.minLength || value.length > slot.length) {
                return PlateValidation.invalid(REASON_FIELD)
            }
        }
        val region = entry.group("region")
        if (region.isNotEmpty() && region !in transnistriaRegions) return PlateValidation.invalid(REASON_REGION)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_FIELD = "A field has the wrong length or letters."
        const val REASON_REGION = "The region letter is not in use."
    }
}

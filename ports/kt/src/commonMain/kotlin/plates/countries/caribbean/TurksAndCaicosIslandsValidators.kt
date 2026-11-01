package plates.countries.caribbean

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

private val serialRe = Regex("^[0-9]{1,5}$")

/** Judges a `modern` plate: five digits. */
class TurksAndCaicosIslandsValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) =
        if (isDigitsOfLength(entry.group("serial"), 5)) PlateValidation.valid else PlateValidation.invalid(REASON_SERIAL)

    companion object {
        const val REASON_SERIAL = "The number is five digits."
    }
}

/** Judges a `prefixed` or `selfDrive` plate: `TC` and one to five digits. */
class TurksAndCaicosIslandsPrefixedValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("prefix") != "TC") return PlateValidation.invalid(REASON_PREFIX)
        if (!serialRe.matches(entry.group("serial"))) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The plate starts with TC."
        const val REASON_SERIAL = "The number is one to five digits."
    }
}

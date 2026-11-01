package plates.countries.caribbean

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

private val prefixRe = Regex("^([A-Z]{2}|TAXI)$")

/** Judges a Virgin Islands plate: `PV` takes five digits, `TAXI` three, every other two-letter prefix four. */
class BritishVirginIslandsValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) = validateFields(entry.group("prefix"), entry.group("serial"))

    companion object {
        const val REASON_PREFIX = "The plate starts with a class prefix: two letters, or TAXI."
        const val REASON_SERIAL = "The serial has the wrong digit count."

        fun digitsFor(prefix: String) = when (prefix) {
            "PV" -> 5
            "TAXI" -> 3
            else -> 4
        }

        fun validateFields(prefix: String, serial: String): PlateValidation {
            if (!prefixRe.matches(prefix)) return PlateValidation.invalid(REASON_PREFIX)
            if (!isDigitsOfLength(serial, digitsFor(prefix))) return PlateValidation.invalid(REASON_SERIAL)
            return PlateValidation.valid
        }
    }
}

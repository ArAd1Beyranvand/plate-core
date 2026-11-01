package plates.countries.federated_states_of_micronesia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Judges a Micronesian plate: one `serial` group of four digits, the same on
 * the Kosrae, Pohnpei and Yap plates. Reports, never bars. */
class FederatedStatesOfMicronesiaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) =
        if (isDigitsOfLength(entry.group("serial"), 4)) PlateValidation.valid else PlateValidation.invalid(REASON_SERIAL)

    companion object {
        const val REASON_SERIAL = "The serial is four digits."
    }
}

package plates.countries.mali

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

/** Advisory validator for the `XX #### XX` format. */
class MaliValidator : GatedPlateValidator() {
    override val gateGroup = "suffix"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("prefix").length != 2 || entry.group("number").length != 4 || entry.group("suffix").length != 2) {
            return PlateValidation.invalid(REASON_FORMAT)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_FORMAT = "Format is 2 letters, 4 digits, 2 letters."
    }
}

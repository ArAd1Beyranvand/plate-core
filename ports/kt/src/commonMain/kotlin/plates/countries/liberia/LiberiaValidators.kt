package plates.countries.liberia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

private val missionRe = Regex("^[0-9]{1,3}$")
private val statusRe = Regex("^CM?D$")
private val numberRe = Regex("^[0-9]{1,2}$")

/** Judges a diplomatic plate: one to three digits, `CD` or `CMD`, then one or two digits (`1 CD 13`). */
class LiberiaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!missionRe.matches(entry.group("mission"))) return PlateValidation.invalid(REASON_MISSION)
        if (!statusRe.matches(entry.group("status"))) return PlateValidation.invalid(REASON_STATUS)
        if (!numberRe.matches(entry.group("number"))) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_MISSION = "The mission is one to three digits."
        const val REASON_STATUS = "The status is CD or CMD."
        const val REASON_NUMBER = "The number is one or two digits."
    }
}

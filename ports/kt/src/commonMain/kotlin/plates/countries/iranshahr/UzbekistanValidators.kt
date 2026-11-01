package plates.countries.iranshahr

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

private const val NOT_FOUND = "COUNTRY NOT FOUND"
private val refusedMissions = listOf("011")
private val missionCodes = setOf(
    "001", "002", "003", "004", "005", "006", "007", "008", "009", "010", "020", "012", "013", "014", "015", "016", "017", "018",
    "021", "022", "023", "025", "026", "029", "030", "031", "032", "033", "035", "036", "037", "038", "039", "040", "041", "043",
    "044", "046", "052",
)

/** Regional plates: once the region is started, every keyed group must be full. */
class UzbekistanValidator : GatedPlateValidator() {
    override val gateGroup = "region"

    override fun judge(entry: PlateEntry): PlateValidation {
        for (g in entry.spec.textGroups) {
            val key = g.key ?: continue
            val expected = g.indices.sumOf { entry.spec.slots[it].length }
            if (entry.group(key).length != expected) return PlateValidation.invalid("The $key is incomplete.")
        }
        return PlateValidation.valid
    }
}

/** Diplomatic plates carry no region: a mission code and a serial, refusing `011` on its own account as well as through the spec's restriction. */
class UzbekistanDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "mission"

    override fun validate(entry: PlateEntry): PlateValidation {
        if (entry.group("mission") in refusedMissions) return PlateValidation.invalid(NOT_FOUND)
        return super.validate(entry)
    }

    override fun judge(entry: PlateEntry): PlateValidation {
        val mission = entry.group("mission")
        if (mission.length != 3) return PlateValidation.invalid("The mission code is incomplete.")
        if (mission !in missionCodes) return PlateValidation.invalid(NOT_FOUND)
        if (entry.group("serial").length != 3) return PlateValidation.invalid("The serial is incomplete.")
        return PlateValidation.valid
    }
}

/** UN plates, `UN 0123`: four digits, no region. */
class UzbekistanUnitedNationsValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) =
        if (isDigitsOfLength(entry.group("serial"), 4)) PlateValidation.valid else PlateValidation.invalid("The serial is incomplete.")
}

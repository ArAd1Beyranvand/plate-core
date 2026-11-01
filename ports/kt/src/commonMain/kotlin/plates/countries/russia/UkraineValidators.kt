package plates.countries.russia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

private const val NOT_FOUND = "COUNTRY NOT FOUND"

private const val REFUSED = "012"

// Codes of UkraineMissions' table; only membership is judged here.
private val missionCodes = setOf(
    "002", "003", "004", "005", "006", "007", "008", "009", "010", "011", "013", "014",
    "015", "017", "018", "019", "020", "021", "022", "023", "024", "025", "026", "027",
    "028", "029", "030", "031", "032", "033", "034", "035", "036", "037", "038", "039",
    "040", "041", "042", "043", "044", "045", "046", "047", "048", "049", "050", "051",
    "052", "053", "054", "055", "056", "057", "058", "059", "060", "061", "062", "063",
    "064", "065", "066", "067", "068", "069", "070", "071", "072", "073", "074", "075",
    "076", "077", "078", "079", "080", "081", "082", "083", "084", "085", "086", "087",
    "088", "089", "090", "091", "092", "093", "094", "095", "096", "097", "098", "099",
    "100", "199", "206",
)

/** Judges a Ukrainian plate field by field; a diplomatic `mission` is checked against the mission table and `012` is refused. Advisory. */
class UkraineValidator : GatedPlateValidator() {
    override val gateGroup = "series"

    override fun validate(entry: PlateEntry): PlateValidation {
        if (entry.group("mission") == REFUSED) return PlateValidation.invalid(NOT_FOUND)
        return super.validate(entry)
    }

    override fun judge(entry: PlateEntry): PlateValidation {
        for (g in entry.spec.textGroups) {
            val key = g.key ?: continue
            if (entry.group(key).isEmpty()) return PlateValidation.invalid("The $key is incomplete.")
        }
        val mission = entry.group("mission")
        if (mission.isNotEmpty() && mission !in missionCodes) return PlateValidation.invalid(NOT_FOUND)
        return PlateValidation.valid
    }
}

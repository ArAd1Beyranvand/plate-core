package plates.countries.namibia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.restrictionVerdict

/** The town codes, from the article's list (which it says may be incomplete). */
object NamibiaTowns {
    val all = mapOf(
        "A" to "Arandis", "AR" to "Aranos", "B" to "Bethanien", "BK" to "Bukalo",
        "DV" to "Divundu", "EN" to "Eenhana", "G" to "Grootfontein", "GO" to "Gobabis",
        "HB" to "Henties Bay", "HN" to "Helao Nafidi", "K" to "Keetmanshoop",
        "KA" to "Karasburg", "KH" to "Khorixas", "KM" to "Katima Mulilo",
        "KR" to "Karibib", "KO" to "Okongo", "L" to "Lüderitz", "M" to "Mariental",
        "MA" to "Maltahöhe", "MT" to "Omuthiya", "ND" to "Ondangwa", "NK" to "Nkurenkuru",
        "OA" to "Okahao", "OH" to "Okahandja", "OJ" to "Outjo", "OK" to "Okakarara",
        "OM" to "Omaruru", "ON" to "Otjinene", "OP" to "Opuwo", "OR" to "Oranjemund",
        "OT" to "Otjiwarongo", "OV" to "Otavi", "R" to "Rehoboth", "RC" to "Ruacana",
        "RU" to "Rundu", "S" to "Swakopmund", "SH" to "Oshakati", "T" to "Tsumeb",
        "TK" to "Tsumkwe", "U" to "Usakos", "UP" to "Outapi", "W" to "Windhoek",
        "WB" to "Walvis Bay",
    )

    fun name(code: String): String? = all[code]
}

/** A standard plate: every slot filled and the town code on the list. Gated on the town code, which is typed last. */
class NamibiaPlateValidator : GatedPlateValidator() {
    override val gateGroup = "region"

    override fun judge(entry: PlateEntry): PlateValidation {
        incomplete(entry)?.let { return it }
        if (NamibiaTowns.name(entry.group("region")) == null) return PlateValidation.invalid("Unknown town code.")
        return PlateValidation.valid
    }
}

/** Personalised, diplomatic and government plates: every slot filled. */
class NamibiaCompleteValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation =
        restrictionVerdict(entry) ?: incomplete(entry) ?: PlateValidation.valid
}

private fun incomplete(entry: PlateEntry): PlateValidation? {
    for (g in entry.spec.textGroups) {
        val key = g.key ?: continue
        val want = g.indices.fold(0) { n, i -> n + entry.spec.slots[i].length }
        if (entry.group(key).length != want) return PlateValidation.invalid("The $key is incomplete.")
    }
    return null
}

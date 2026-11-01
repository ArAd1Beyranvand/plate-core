package plates.countries.russia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// Keys of BelarusMissions's register; '09' is refused and absent.
private val belarusMissions = setOf(
    "01", "02", "03", "04", "05", "06", "07", "08", "10", "11", "12", "13",
    "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25",
    "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37",
    "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49",
    "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61",
    "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73",
    "74", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85",
    "86",
)

private const val NOT_FOUND = "COUNTRY NOT FOUND"
private val refused = listOf("09")

/** Every Belarusian number ends in a region digit; the validator stays quiet until it is filled. Advisory, except for the spec's restrictions, which [GatedPlateValidator] reports first. */
open class BelarusPlateValidator : GatedPlateValidator() {
    override val gateGroup = "region"

    override fun judge(entry: PlateEntry): PlateValidation {
        for (g in entry.spec.textGroups) {
            val key = g.key ?: continue
            if (entry.group(key).length != g.indices.size) return PlateValidation.invalid("The $key is incomplete.")
        }
        return PlateValidation.valid
    }
}

/** [BelarusPlateValidator] plus the mission register. Refuses `09` on its own account as well. */
class BelarusDiplomaticValidator : BelarusPlateValidator() {
    override fun validate(entry: PlateEntry): PlateValidation {
        if (entry.group("mission") in refused) return PlateValidation.invalid(NOT_FOUND)
        return super.validate(entry)
    }

    override fun judge(entry: PlateEntry): PlateValidation {
        val verdict = super.judge(entry)
        if (!verdict.isValid) return verdict
        if (entry.group("mission") !in belarusMissions) return PlateValidation.invalid(NOT_FOUND)
        return verdict
    }
}

/** Service plates (`1234 MO`) carry no region digit; gated on the letters. */
class BelarusServiceValidator : GatedPlateValidator() {
    override val gateGroup = "letters"

    override fun judge(entry: PlateEntry) =
        if (isDigitsOfLength(entry.group("serial"), 4)) PlateValidation.valid
        else PlateValidation.invalid("The serial is incomplete.")
}

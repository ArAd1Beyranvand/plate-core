package plates.countries.myanmar

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** The region codes of Table 2 and the highest township numeral each takes. */
val myanmarRegions = mapOf(
    "AYY" to 26, "BGO" to 28, "CHN" to 9, "KYH" to 7, "KCN" to 18, "KYN" to 7, "MGY" to 25,
    "MDY" to 28, "MON" to 10, "NPW" to 8, "RKE" to 17, "SGG" to 37, "SHN" to 55, "TNI" to 10,
    "YGN" to 45,
)

/** Judges a plate with a `region` group (`YGN-36`) and a four-digit `serial`; the township is checked against its region's range. */
class MyanmarValidator : GatedPlateValidator() {
    override val gateGroup = "region"

    override fun judge(entry: PlateEntry): PlateValidation {
        val max = myanmarRegions[entry.group("region")] ?: return PlateValidation.invalid(REASON_REGION)
        val township = entry.group("township").trim()
        if (township.isNotEmpty()) {
            val n = township.toIntOrNull()
            if (n == null || n < 1 || n > max) return PlateValidation.invalid(REASON_TOWNSHIP)
        }
        if (!isDigitsOfLength(entry.group("serial"), 4)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_REGION = "The region is not a Myanmar code."
        const val REASON_TOWNSHIP = "The township is out of range."
        const val REASON_SERIAL = "The number is four digits."
    }
}

/** Judges a Burmese-script motorcycle or rickshaw plate: three characters over five numerals. */
class MyanmarBurmeseValidator : GatedPlateValidator() {
    override val gateGroup = "letters"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("letters").length != 3) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(entry.group("serial"), 5)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The top row is three characters."
        const val REASON_SERIAL = "The number is five numerals."
    }
}

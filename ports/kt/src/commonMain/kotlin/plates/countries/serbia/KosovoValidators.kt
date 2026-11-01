package plates.countries.serbia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

/** The district codes opening a plate: 01 Pristina to 07 Gjakova. */
object KosovoDistricts {
    val names = mapOf(
        "01" to "Pristina", "02" to "Mitrovica", "03" to "Peja", "04" to "Prizren",
        "05" to "Ferizaj", "06" to "Gjilan", "07" to "Gjakova",
    )
}

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val district = Regex("^0[1-7]$")
private val twoDigits = Regex("^[0-9]{2}$")
private val threeDigits = Regex("^[0-9]{3}$")
private val twoLetters = Regex("^[A-Z]{2}$")

private val districtPlate = mapOf("region" to district, "serial" to threeDigits, "series" to twoLetters)

private val formats = mapOf(
    "xk.private" to districtPlate,
    "xk.agriculture" to districtPlate,
    "xk.trailer" to districtPlate,
    "xk.moped" to districtPlate,
    "xk.government" to mapOf("agency" to Regex("^[0-9][A-Z]$"), "serial" to threeDigits, "series" to twoDigits),
    "xk.police" to mapOf("serial" to threeDigits, "series" to twoDigits),
    "xk.emergency" to mapOf("service" to threeDigits, "serial" to threeDigits, "series" to twoDigits),
    "xk.customs" to mapOf("serial" to threeDigits, "series" to twoLetters),
    "xk.military" to mapOf("unit" to Regex("^[A-Z]{3}$"), "serial" to threeDigits, "series" to twoDigits),
    "xk.unmik" to mapOf("serial" to threeDigits, "mark" to twoLetters, "series" to threeDigits),
    "xk.diplomatic" to mapOf("region" to twoDigits, "mark" to twoLetters, "series" to threeDigits),
    "xk.eulex" to mapOf("series" to Regex("^[0-9]{4}$")),
)

/** Judges a Kosovar plate field by field. Reports, never bars a keystroke. */
class KosovoValidator : GatedPlateValidator() {
    override val gateGroup = "series"

    override fun judge(entry: PlateEntry): PlateValidation {
        val format = formats[entry.spec.id] ?: return PlateValidation.valid
        for ((key, re) in format) {
            if (!re.matches(entry.group(key))) {
                return PlateValidation.invalid(if (key == "region") REASON_DISTRICT else REASON)
            }
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON = "The plate does not match its format."
        const val REASON_DISTRICT = "The district code is 01 to 07."
    }
}

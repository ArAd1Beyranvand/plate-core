package plates.countries.indonesia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

/** The area codes the article lists as in use, by police region. Non-motorised codes (SB, YB, YK, KS) are issued plates. */
private val areaCodes = setOf(
    "BL", "BB", "BK", "BA", "BM", "BP", "BH", "BD", "BG", "BN", "BE",
    "A", "B", "F", "T", "E", "D", "Z", "R", "G", "H", "K", "AA", "AD", "AB",
    "AE", "AG", "S", "W", "L", "M", "N", "P",
    "KB", "KH", "DA", "KT", "KU",
    "DL", "DB", "DM", "DN", "DC", "DP", "DW", "DD", "DT",
    "DK", "DR", "EA", "ED", "EB", "DH",
    "DE", "DG", "PA", "PB", "PG", "PS", "PT", "PY",
    "SB", "YB", "YK", "KS",
)

private val policeRegions = "I II III IV V VI VII VIII IX X XI XII XIII XIV XV XVI XVII XVIII XIX XX XXI XXII XXIII XXIV XXV XXVI XXVII XXVIII XXIX XXX XXXI XXXII XXXIII XXXIV XXXV".split(" ").toSet()

/**
 * Judges a registration on a car or motorcycle spec. Checks what the article states: the area code is one it lists;
 * the number runs 1-9999 with no leading zero; the suffix is at most three letters; the expiry month is 01-12.
 */
class IndonesiaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry) = validateFields(
        prefix = entry.group("prefix"),
        number = entry.group("number"),
        suffix = entry.group("suffix"),
        month = entry.group("month"),
    )

    companion object {
        const val REASON_AREA = "Not an Indonesian area code."
        const val REASON_NUMBER = "The number is 1 to 9999."
        const val REASON_LEADING_ZERO = "The number has no leading zero."
        const val REASON_SUFFIX = "The suffix is up to three letters."
        const val REASON_MONTH = "The expiry month is 01 to 12."

        fun validateFields(prefix: String, number: String, suffix: String = "", month: String = ""): PlateValidation {
            if (prefix !in areaCodes) return PlateValidation.invalid(REASON_AREA)
            if (number.isEmpty() || number.length > 4 || !isDigits(number)) return PlateValidation.invalid(REASON_NUMBER)
            if (number.startsWith("0")) return PlateValidation.invalid(REASON_LEADING_ZERO)
            if (suffix.length > 3) return PlateValidation.invalid(REASON_SUFFIX)
            if (month.isNotEmpty()) {
                val m = if (isDigits(month)) month.toIntOrNull() else null
                if (month.length != 2 || m == null || m < 1 || m > 12) return PlateValidation.invalid(REASON_MONTH)
            }
            return PlateValidation.valid
        }
    }
}

/** Judges a diplomatic value: `CD` or `CC`, the mission's number and the vehicle's. */
class IndonesiaDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("mission") !in listOf("CD", "CC")) return PlateValidation.invalid(REASON_MISSION)
        if (!isDigits(entry.group("country")) || !isDigits(entry.group("serial"))) return PlateValidation.invalid(REASON_DIGITS)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_MISSION = "The code is CD or CC."
        const val REASON_DIGITS = "Both numbers are digits."
    }
}

/** Judges a military or police value: a 1-99999 number with no leading zero, a two-digit suffix and, on a police plate, a listed region numeral. */
class IndonesiaServiceValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val number = entry.group("number")
        if (number.isEmpty() || !isDigits(number) || number.startsWith("0")) return PlateValidation.invalid(REASON_NUMBER)
        val suffix = entry.group("suffix")
        if (suffix.length != 2 || !isDigits(suffix)) return PlateValidation.invalid(REASON_SUFFIX)
        if (entry.spec.textGroups.any { it.key == "region" } && entry.group("region") !in policeRegions) {
            return PlateValidation.invalid(REASON_REGION)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is 1 to 99999."
        const val REASON_SUFFIX = "The suffix is two digits."
        const val REASON_REGION = "Not a police region numeral."
    }
}

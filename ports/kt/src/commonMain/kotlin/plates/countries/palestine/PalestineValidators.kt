package plates.countries.palestine

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

private val governorateLetters = listOf("A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N")
private val districtCodes = listOf("1", "3", "4", "5", "6", "7", "8", "9")
private val twoDigits = Regex("^[0-9][0-9]$")

private val legacyCodes = setOf(
    "30", "31", "32",
    "40", "41", "42", "43", "44", "45", "46", "47", "48", "49",
    "90", "91", "92", "93", "94", "95", "96", "97", "98", "99",
)

private fun gazaUsageLegal(code: String): Boolean {
    if (!twoDigits.matches(code)) return false
    val n = code.toInt()
    return n <= 29 || n in 40..59
}

/** Modern West Bank plate validator (D-DDDD-L). Quiet until the governorate is filled. */
class PSWestBankModernValidator : GatedPlateValidator() {
    override val gateGroup = "governorate"

    override fun judge(entry: PlateEntry) =
        validateFields(entry.group("region"), entry.group("serial"), entry.group("governorate"))

    companion object {
        const val INVALID_REGION = "Region code must be one digit."
        const val INVALID_SERIAL = "Serial must be four digits."
        const val ILLEGAL_LETTER_IO = "The letters I and O are never issued; H is followed by J."
        const val RESERVED_GAZA_LETTER = "P, Q, R, S and T were allocated to Gaza and never issued."
        const val INVALID_GOVERNORATE = "Governorate letter must be one of A-N (I and O excluded)."

        fun validateFields(region: String, serial: String, governorate: String): PlateValidation {
            if (!isDigitsOfLength(region, 1)) return PlateValidation.invalid(INVALID_REGION)
            if (!isDigitsOfLength(serial, 4)) return PlateValidation.invalid(INVALID_SERIAL)
            if (governorate == "I" || governorate == "O") return PlateValidation.invalid(ILLEGAL_LETTER_IO)
            if (governorate in listOf("P", "Q", "R", "S", "T")) return PlateValidation.invalid(RESERVED_GAZA_LETTER)
            if (governorate.length != 1 || governorate !in governorateLetters) return PlateValidation.invalid(INVALID_GOVERNORATE)
            return PlateValidation.valid
        }
    }
}

/** Legacy West Bank plate validator (D-DDDD-DD). Quiet until the usage code is filled. */
class PSWestBankLegacyValidator : GatedPlateValidator() {
    override val gateGroup = "usage"

    override fun judge(entry: PlateEntry) =
        validateFields(entry.group("district"), entry.group("serial"), entry.group("usage"))

    companion object {
        const val INVALID_DISTRICT_CODE = "District code must be 1 or 3-9 (0 and 2 are never issued)."
        const val INVALID_SERIAL = "Serial must be four digits."
        const val INVALID_USAGE_CODE = "Usage code is not a legal class (see PSLegacyUsage.codes)."

        fun validateFields(district: String, serial: String, usage: String): PlateValidation {
            if (district.length != 1 || district !in districtCodes) return PlateValidation.invalid(INVALID_DISTRICT_CODE)
            if (!isDigitsOfLength(serial, 4)) return PlateValidation.invalid(INVALID_SERIAL)
            if (usage !in legacyCodes) return PlateValidation.invalid(INVALID_USAGE_CODE)
            return PlateValidation.valid
        }
    }
}

/** Gaza plate validator (3-DDDD-DD). Quiet until the usage code is filled. */
class PSGazaValidator : GatedPlateValidator() {
    override val gateGroup = "usage"

    override fun judge(entry: PlateEntry) =
        validateFields(entry.group("prefix"), entry.group("serial"), entry.group("usage"))

    companion object {
        const val GAZA_PREFIX_NOT_THREE = "A Gaza plate always begins with 3."
        const val INVALID_SERIAL = "Serial must be four digits."
        const val INVALID_USAGE_CODE = "Usage code is not a legal Gaza class (00-29 or 40-59)."

        fun validateFields(prefix: String, serial: String, usage: String): PlateValidation {
            if (prefix != "3") return PlateValidation.invalid(GAZA_PREFIX_NOT_THREE)
            if (!isDigitsOfLength(serial, 4)) return PlateValidation.invalid(INVALID_SERIAL)
            if (!gazaUsageLegal(usage)) return PlateValidation.invalid(INVALID_USAGE_CODE)
            return PlateValidation.valid
        }
    }
}

package plates.countries.romania

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

/** The county codes, from the article's table (Bucharest is `B`; `IF` is Ilfov, which surrounds it). */
object RomaniaCounties {
    val names = mapOf(
        "B" to "Bucharest",
        "AB" to "Alba",
        "AG" to "Argeș",
        "AR" to "Arad",
        "BC" to "Bacău",
        "BH" to "Bihor",
        "BN" to "Bistrița-Năsăud",
        "BR" to "Brăila",
        "BT" to "Botoșani",
        "BV" to "Brașov",
        "BZ" to "Buzău",
        "CJ" to "Cluj",
        "CL" to "Călărași",
        "CS" to "Caraș-Severin",
        "CT" to "Constanța",
        "CV" to "Covasna",
        "DB" to "Dâmbovița",
        "DJ" to "Dolj",
        "GJ" to "Gorj",
        "GL" to "Galați",
        "GR" to "Giurgiu",
        "HD" to "Hunedoara",
        "HR" to "Harghita",
        "IF" to "Ilfov",
        "IL" to "Ialomița",
        "IS" to "Iași",
        "MH" to "Mehedinți",
        "MM" to "Maramureș",
        "MS" to "Mureș",
        "NT" to "Neamț",
        "OT" to "Olt",
        "PH" to "Prahova",
        "SB" to "Sibiu",
        "SJ" to "Sălaj",
        "SM" to "Satu Mare",
        "SV" to "Suceava",
        "TL" to "Tulcea",
        "TM" to "Timiș",
        "TR" to "Teleorman",
        "VL" to "Vâlcea",
        "VN" to "Vrancea",
        "VS" to "Vaslui",
    )
}

private fun county(code: String) = code in RomaniaCounties.names

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val lettersRe = Regex("^[A-HJ-NP-Z][A-PR-Z]{2}$")

/** Judges a `RomaniaPlates.standard` value: a county code, two digits (three in Bucharest, never `00`) and three letters without Q or a leading I or O. Advisory: reports, never bars a keystroke. */
class RomaniaValidator : GatedPlateValidator() {
    override val gateGroup = "letters"

    override fun judge(entry: PlateEntry): PlateValidation {
        val county = entry.group("county")
        if (!county(county)) return PlateValidation.invalid(REASON_COUNTY)
        val number = entry.group("number")
        val lengthOk = number.length == 2 || (county == "B" && number.length == 3)
        if (!lengthOk || !isDigits(number) || number.toInt() == 0) return PlateValidation.invalid(REASON_NUMBER)
        val letters = entry.group("letters")
        if (!lettersRe.matches(letters) || 'Q' in letters) return PlateValidation.invalid(REASON_LETTERS)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_COUNTY = "The county code is one of the 42 codes."
        const val REASON_NUMBER = "The number is two digits, or two or three in Bucharest; not 00."
        const val REASON_LETTERS = "The letters are three, without Q, and do not begin with I or O."
    }
}

/** Judges a `RomaniaPlates.temporary` value: a county code and three to six digits, the first `0` and the second not. */
class RomaniaTemporaryValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!county(entry.group("county"))) return PlateValidation.invalid(RomaniaValidator.REASON_COUNTY)
        val n = entry.group("number")
        if (n.length < 3 || !isDigits(n) || n[0] != '0' || n[1] == '0') return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is three to six digits, the first 0 and the second not."
    }
}

/** Judges a `RomaniaPlates.test` value: a county code and a three-digit number from 101. */
class RomaniaTestValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!county(entry.group("county"))) return PlateValidation.invalid(RomaniaValidator.REASON_COUNTY)
        val n = entry.group("number")
        if (!isDigitsOfLength(n, 3) || n.toInt() < 101) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is three digits, from 101."
    }
}

/** Judges a `RomaniaPlates.diplomatic` value: `CD`, `TC` or `CO` and two three-digit codes, the lowest of either being 101. The mission code is only range-checked. */
class RomaniaDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "rank"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("code") !in setOf("CD", "TC", "CO")) return PlateValidation.invalid(REASON_CODE)
        for (key in listOf("mission", "rank")) {
            val v = entry.group(key)
            if (!isDigitsOfLength(v, 3) || v.toInt() < 101) return PlateValidation.invalid(REASON_DIGITS)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_CODE = "The code is CD, TC or CO."
        const val REASON_DIGITS = "The mission and the rank are each three digits, from 101."
    }
}

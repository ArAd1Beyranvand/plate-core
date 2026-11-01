package plates.countries.philippines

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isDigits

private val lettersRe = Regex("^[A-Z]+$")
private val allZeros = Regex("^0+$")
private val hasLetter = Regex("[A-Z]")
private val hasDigit = Regex("[0-9]")

private const val NOT_FOUND = "COUNTRY NOT FOUND"
private val refused = listOf("036")

private val missions: Map<String, String> = mapOf(
        "001" to "Vatican City/Holy See",
        "002" to "Egypt",
        "003" to "Australia",
        "004" to "Belgium",
        "005" to "Brazil",
        "006" to "Chile",
        "007" to "Panama",
        "008" to "United Kingdom",
        "009" to "United States",
        "010" to "Colombia",
        "011" to "Ireland",
        "012" to "Denmark",
        "013" to "Austria",
        "014" to "Sweden",
        "015" to "France",
        "016" to "Italy",
        "017" to "Spain",
        "018" to "Norway",
        "019" to "Argentina",
        "020" to "South Korea",
        "021" to "Turkey",
        "022" to "Thailand",
        "023" to "Pakistan",
        "024" to "India",
        "025" to "Canada",
        "026" to "Indonesia",
        "027" to "Greece",
        "028" to "Netherlands",
        "029" to "Mexico",
        "030" to "Germany",
        "031" to "Laos",
        "032" to "Finland",
        "033" to "Japan",
        "034" to "Switzerland",
        "035" to "Myanmar",
        "037" to "Cambodia",
        "038" to "Sri Lanka",
        "039" to "Nigeria",
        "040" to "South Africa",
        "041" to "Iran",
        "042" to "European Union",
        "043" to "Malaysia",
        "044" to "New Zealand",
        "045" to "Venezuela",
        "046" to "Singapore",
        "047" to "Saudi Arabia",
        "048" to "Bangladesh",
        "049" to "Romania",
        "050" to "Poland",
        "051" to "Hungary",
        "052" to "Czech Republic",
        "053" to "United Arab Emirates",
        "054" to "Iraq",
        "055" to "Morocco",
        "056" to "China",
        "057" to "Papua New Guinea",
        "058" to "Russia",
        "059" to "Vietnam",
        "060" to "Kuwait",
        "061" to "Libya",
        "062" to "Oman",
        "063" to "Qatar",
        "064" to "Brunei",
        "065" to "Sovereign Military Order of Malta",
        "066" to "Palestine",
        "067" to "Palau",
        "068" to "Angola",
        "069" to "Timor-Leste",
        "070" to "Bahrain",
        "071" to "Yemen",
        "072" to "Ukraine",
        "073" to "Lebanon",
        "074" to "Jordan",
        "075" to "Kazakhstan",
        "200" to "Taipei Economic and Cultural Office in the Philippines",
        "201" to "United Nations",
        "202" to "UNICEF",
        "203" to "World Health Organization",
        "204" to "United Nations Industrial Development Organization",
        "205" to "Asian Development Bank",
        "206" to "World Trade Organization",
        "207" to "World Food Programme",
        "208" to "International Labour Organization",
        "209" to "United States Agency for International Development",
        "210" to "United Nations Information Centres",
        "211" to "United Nations Development Programme",
        "212" to "Food and Agriculture Organization",
        "213" to "International Monetary Fund",
        "214" to "United Nations High Commissioner for Refugees",
        "215" to "International Committee of the Red Cross",
        "216" to "International Finance Corporation",
        "217" to "World Bank",
        "218" to "Canadian International Development Agency",
        "219" to "Japan International Cooperation Agency",
        "220" to "United Nations Population Fund",
        "221" to "International Organization for Migration",
        "222" to "ASEAN Centre for Biodiversity",
        "223" to "International Rice Research Institute",
        "224" to "Japan Bank for International Cooperation",
        "225" to "Swedish International Development Cooperation Agency",
)

/** Judges a car or vintage plate; gated on the number. [government] allows the S series. */
class PhilippinesValidator(val government: Boolean = false) : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val letters = entry.group("letters")
        val number = entry.group("number")
        if (letters.length != 3 || !lettersRe.matches(letters)) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigits(number)) return PlateValidation.invalid(REASON_NUMBER)
        if (allZeros.matches(number)) return PlateValidation.invalid(REASON_ZERO)
        if (letters.startsWith("S") && !government) return PlateValidation.invalid(REASON_GOVERNMENT)
        if (entry.spec.indicesOfGroup("year").isNotEmpty()) {
            if (letters.substring(1) !in listOf("TX", "TY", "TZ")) return PlateValidation.invalid(REASON_VINTAGE)
            if (!isDigitsOfLength(entry.group("year"), 4)) return PlateValidation.invalid(REASON_YEAR)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "A plate starts with three letters."
        const val REASON_NUMBER = "The number is all digits."
        const val REASON_ZERO = "The number is never all zeros."
        const val REASON_GOVERNMENT = "S is reserved for government vehicles."
        const val REASON_VINTAGE = "A vintage plate ends in TX, TY or TZ."
        const val REASON_YEAR = "The year is four digits."
    }
}

/** Judges a motorcycle plate: six characters with at least one letter and one digit. */
class PhilippinesMotorcycleValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val serial = entry.group("serial")
        if (serial.length != 6) return PlateValidation.invalid(REASON_LENGTH)
        if (!hasLetter.containsMatchIn(serial) || !hasDigit.containsMatchIn(serial)) return PlateValidation.invalid(REASON_MIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LENGTH = "A motorcycle plate has six characters."
        const val REASON_MIX = "A motorcycle plate mixes letters and digits."
    }
}

/** Judges a diplomatic plate: a listed mission code and a four-digit serial. Refuses `036` itself. */
class PhilippinesDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "mission"

    override fun validate(entry: PlateEntry): PlateValidation {
        if (entry.group("mission") in refused) return PlateValidation.invalid(NOT_FOUND)
        return super.validate(entry)
    }

    override fun judge(entry: PlateEntry): PlateValidation {
        if (missions[entry.group("mission")] == null) return PlateValidation.invalid(NOT_FOUND)
        if (!isDigitsOfLength(entry.group("serial"), 4)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_SERIAL = "The serial is four digits."
    }
}

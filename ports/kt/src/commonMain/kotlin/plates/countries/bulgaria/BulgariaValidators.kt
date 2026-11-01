package plates.countries.bulgaria

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val series = Regex("^[ABKMHPCTX]{1,2}$")

// Province codes (BulgariaAlphabets.regionCodes); `EA` and `EM` are validated separately.
private val regionCodes = setOf(
    "A", "B", "BH", "BP", "BT", "E", "EB", "EH", "K", "KH", "M", "H", "OB",
    "P", "PA", "PB", "PK", "PP", "C", "CA", "CB", "CH", "CM", "CO", "CC",
    "CT", "T", "TX", "Y", "X",
)

/**
 * Judges a registration plate (`C 5096 MK`) by its `region`, `number` and `series` registers: a province code
 * from the table (or `EA`/`EM`), four digits and a series of one or two of the nine series letters.
 * Reports, never bars a keystroke.
 */
class BulgariaValidator : GatedPlateValidator() {
    override val gateGroup = "series"

    override fun judge(entry: PlateEntry): PlateValidation {
        val region = entry.group("region")
        if (region !in regionCodes && region != "EA" && region != "EM") return PlateValidation.invalid(REASON_REGION)
        if (!isDigitsOfLength(entry.group("number"), 4)) return PlateValidation.invalid(REASON_NUMBER)
        return if (series.matches(entry.group("series"))) PlateValidation.valid else PlateValidation.invalid(REASON_SERIES)
    }

    companion object {
        const val REASON_REGION = "The province code is not one of the table."
        const val REASON_NUMBER = "The number is four digits."
        const val REASON_SERIES = "The series is one or two of A B K M H P C T X."
    }
}

/** Judges the army `BA 509 096` and civil-protection `CP 59 096` plates by their `code`, `first` and `second` registers. */
class BulgariaServiceValidator : GatedPlateValidator() {
    override val gateGroup = "second"

    override fun judge(entry: PlateEntry): PlateValidation {
        val code = entry.group("code")
        if (code != "BA" && code != "CP") return PlateValidation.invalid(REASON_CODE)
        val ok = isDigitsOfLength(entry.group("first"), if (code == "BA") 3 else 2) &&
            isDigitsOfLength(entry.group("second"), 3)
        return if (ok) PlateValidation.valid else PlateValidation.invalid(REASON_DIGITS)
    }

    companion object {
        const val REASON_CODE = "The code is BA (army) or CP (civil protection)."
        const val REASON_DIGITS = "BA takes 3 + 3 digits, CP 2 + 3."
    }
}

/**
 * Judges a foreigner's plate (`XX 9043 19`, `XH` since 2019) and a diplomatic one (`CC 7711 20`) by their
 * `region` and `year`, and, for a diplomatic plate, the `mission` and `number` registers. The mission `22`
 * is refused on its own account as well as by the spec's restriction.
 */
class BulgariaStampedValidator : GatedPlateValidator() {
    override val gateGroup = "year"

    override fun validate(entry: PlateEntry): PlateValidation =
        if (entry.group("mission") in REFUSED_MISSIONS) PlateValidation.invalid(NOT_FOUND) else super.validate(entry)

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("region") !in listOf("XX", "XH", "C", "CC", "CT")) return PlateValidation.invalid(REASON_PREFIX)
        val digits = if (entry.spec.textGroups.any { it.key == "mission" }) {
            isDigitsOfLength(entry.group("mission"), 2) && isDigitsOfLength(entry.group("number"), 2)
        } else {
            isDigitsOfLength(entry.group("number"), 4)
        }
        return if (digits && isDigitsOfLength(entry.group("year"), 2)) PlateValidation.valid
        else PlateValidation.invalid(REASON_DIGITS)
    }

    companion object {
        /** The error every layer shows for a refused mission code (BulgariaMissions.notFound). */
        const val NOT_FOUND = "COUNTRY NOT FOUND"
        val REFUSED_MISSIONS = listOf("22")

        const val REASON_PREFIX = "Foreigners are XX or XH; diplomats C, CC or CT."
        const val REASON_DIGITS = "Four digits (a diplomat's two mission digits, then two) and a two-digit year."
    }
}

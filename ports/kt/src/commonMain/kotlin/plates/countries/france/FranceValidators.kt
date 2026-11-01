package plates.countries.france

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters = Regex("^[A-HJ-NP-TV-Z]{2}$")
private val departmentRe = Regex("^(0[1-9]|1[0-9]|2[1-9]|[3-8][0-9]|9[0-5]|2A|2B)$")
private val monthRe = Regex("^(0[1-9]|1[0-2])$")

/** Judges a French SIV plate; [temporary] plates start WW and regular ones never do. Reports, never bars a keystroke. */
class FranceValidator(val temporary: Boolean = false) : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        val prefix = entry.group("prefix")
        if (!letters.matches(prefix) || prefix == "SS") return PlateValidation.invalid(REASON_PREFIX)
        if (temporary != (prefix == "WW")) return PlateValidation.invalid(REASON_TEMPORARY)
        val number = entry.group("number")
        if (!isDigitsOfLength(number, 3) || number == "000") return PlateValidation.invalid(REASON_NUMBER)
        val suffix = entry.group("suffix")
        if (!letters.matches(suffix) || suffix == "SS") return PlateValidation.invalid(REASON_SUFFIX)
        val department = entry.group("department")
        if (department.isNotEmpty() && !departmentRe.matches(department)) return PlateValidation.invalid(REASON_DEPARTMENT)
        val month = entry.group("month")
        if (month.isNotEmpty() && !monthRe.matches(month)) return PlateValidation.invalid(REASON_MONTH)
        val year = entry.group("year")
        if (year.isNotEmpty() && !isDigitsOfLength(year, 2)) return PlateValidation.invalid(REASON_YEAR)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is two letters (no I, O, U or SS)."
        const val REASON_TEMPORARY = "A temporary plate starts WW."
        const val REASON_NUMBER = "The number is three digits, 001–999."
        const val REASON_SUFFIX = "The suffix is two letters (no I, O, U or SS)."
        const val REASON_DEPARTMENT = "The département is two digits (01–95), 2A or 2B."
        const val REASON_MONTH = "The month is 01–12."
        const val REASON_YEAR = "The year is two digits."
    }
}

/** Judges a diplomatic plate: embassy digits, a status and a series of one to three digits. */
class FranceDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "embassy"

    override fun judge(entry: PlateEntry): PlateValidation {
        val embassy = entry.group("embassy")
        if (!isDigits(embassy) || embassy.length > 3) return PlateValidation.invalid(REASON_EMBASSY)
        if (entry.group("status") !in statuses) return PlateValidation.invalid(REASON_STATUS)
        val series = entry.group("series")
        if (!isDigits(series) || series.length > 3) return PlateValidation.invalid(REASON_SERIES)
        return PlateValidation.valid
    }

    companion object {
        val statuses = listOf("C", "CD", "CMD", "K")

        const val REASON_EMBASSY = "The embassy code is one to three digits."
        const val REASON_STATUS = "The status is C, CD, CMD or K."
        const val REASON_SERIES = "The series is one to three digits."
    }
}

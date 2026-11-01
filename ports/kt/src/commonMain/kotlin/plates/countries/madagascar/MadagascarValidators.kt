package plates.countries.madagascar

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.isLetters
import plates.core.validators.restrictionVerdict

/** Advisory validator over whichever of `number`, `series` and `country` the spec has. Empty groups are not judged. */
class MadagascarValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        val broken = restrictionVerdict(entry)
        if (broken != null) return broken
        val number = entry.group("number")
        val series = entry.group("series")
        val country = entry.group("country")
        if (number.isNotEmpty() && !numberRe.matches(number)) {
            return PlateValidation.invalid(REASON_NUMBER)
        }
        if (country.isNotEmpty()) {
            if (!countryRe.matches(country)) return PlateValidation.invalid(REASON_COUNTRY)
            if (series.isNotEmpty() && series !in diplomaticSeries) {
                return PlateValidation.invalid(REASON_DIPLOMATIC)
            }
        } else if (series.isNotEmpty()) {
            if (!isLetters(series, 1, 3)) return PlateValidation.invalid(REASON_SERIES)
            val province = if (series.startsWith("WW")) series.substring(series.length - 1) else series.substring(0, 1)
            if (series.length > 1 && province !in provinces) {
                return PlateValidation.invalid(REASON_PROVINCE)
            }
        }
        return PlateValidation.valid
    }

    companion object {
        val provinces = setOf("A", "D", "F", "M", "T", "U")
        val diplomaticSeries = setOf("CD", "CMD", "CMC", "PE")

        const val REASON_NUMBER = "The number is one to five digits."
        const val REASON_SERIES = "The series is two or three letters."
        const val REASON_PROVINCE = "The first letter is the province: A, D, F, M, T or U."
        const val REASON_COUNTRY = "The country code is three digits."
        const val REASON_DIPLOMATIC = "The series is CD, CMD, CMC or PE."

        private val numberRe = Regex("^[0-9]{1,5}$")
        private val countryRe = Regex("^[0-9]{3}$")
    }
}

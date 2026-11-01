package plates.countries.germany

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

private val forbiddenLetterPairs = setOf("SS", "SA", "KZ", "HJ", "NS", "AH", "HH", "SD", "IS")
private val forbiddenNumbers = setOf("88", "18", "14")

// H9: explicit ASCII classes. The area code may carry an umlaut; the identifier may not (a deliberate asymmetry).
private val districtPattern = Regex("^[A-ZÄÖÜ]{1,3}$")
private val identifierLetterPattern = Regex("^[A-Z]{1,2}$")

private val daysInMonth = listOf(31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)

/** The five issued identifier shapes (FZV Appendix 1): letters and the inclusive digit range. */
private class IdentifierGroup(val letters: Int, val minDigits: Int, val maxDigits: Int)

private val identifierGroups = listOf(
    IdentifierGroup(1, 1, 3),
    IdentifierGroup(2, 1, 2),
    IdentifierGroup(2, 3, 3),
    IdentifierGroup(1, 4, 4),
    IdentifierGroup(2, 4, 4),
)

private fun districtAndSerialError(district: String, serial: String): PlateValidation? {
    if (!districtPattern.matches(district)) return PlateValidation.invalid("District code must be 1-3 letters.")
    if (!isDigits(serial)) return PlateValidation.invalid("The number must be digits.")
    return null
}

private fun opensWith(prefix: String, serial: String) = prefix.startsWith(serial.take(2))

/** Validates a German car-plate district code + identifier pair. */
class GermanPlateValidator : GatedPlateValidator() {
    override val gateGroup = "letters"

    override fun judge(entry: PlateEntry): PlateValidation {
        val registration = validateFields(entry.group("district"), entry.group("letters"), entry.group("serial"))
        if (!registration.isValid) return registration
        return validateSeason(entry.group("seasonStart"), entry.group("seasonEnd"))
    }

    companion object {
        /** Two months of validity, in any order; quiet about incomplete months. */
        fun validateSeason(start: String, end: String): PlateValidation {
            for (month in listOf(start, end)) {
                if (month.length < 2) continue
                if (!isDigitsOfLength(month, 2)) return PlateValidation.invalid("A season month is two digits.")
                val value = month.toInt()
                if (value < 1 || value > 12) return PlateValidation.invalid("\"$month\" is not a month.")
            }
            return PlateValidation.valid
        }

        fun validateFields(district: String, identifierLetters: String, identifierDigits: String): PlateValidation {
            val d = district.uppercase()
            val letters = identifierLetters.uppercase()
            val digits = identifierDigits

            if (!districtPattern.matches(d)) return PlateValidation.invalid("District code must be 1-3 letters.")
            if (!identifierLetterPattern.matches(letters)) return PlateValidation.invalid("Identifier letters must be 1-2 letters.")
            if (digits.isNotEmpty() && !(isDigits(digits) && digits.length <= 4)) {
                return PlateValidation.invalid("Identifier digits must be 1-4 digits.")
            }
            if (digits.startsWith("0")) return PlateValidation.invalid("The serial cannot start with 0.")
            if (d.length + letters.length + digits.length > 8) return PlateValidation.invalid("Plate exceeds the 8-character maximum.")
            if (digits.isNotEmpty() &&
                identifierGroups.none { it.letters == letters.length && digits.length in it.minDigits..it.maxDigits }
            ) {
                return PlateValidation.invalid(
                    "${letters.length} letter(s) and ${digits.length} digit(s) is not an issued identifier shape.",
                )
            }
            if (letters in forbiddenLetterPairs) return PlateValidation.invalid("\"$letters\" is a forbidden combination.")
            if (d.length == 1 && letters.length == 1 && "$d$letters" in forbiddenLetterPairs) {
                return PlateValidation.invalid("\"$d$letters\" is a forbidden combination.")
            }
            if (digits.isNotEmpty() && digits in forbiddenNumbers) return PlateValidation.invalid("\"$digits\" is a forbidden combination.")
            return PlateValidation.valid
        }
    }
}

/** Validates a `06` dealer or `07` collector plate (the opening pair follows the spec): area code + 5 digits. */
class GermanSerialPlateValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val district = entry.group("district").uppercase()
        val serial = entry.group("serial")
        districtAndSerialError(district, serial)?.let { return it }
        val prefix = if (entry.spec.id == "de.collector") "07" else "06"
        if (!opensWith(prefix, serial)) return PlateValidation.invalid("This number begins \"$prefix\".")
        if (serial.length > 5) return PlateValidation.invalid("The number is five digits.")
        return PlateValidation.valid
    }
}

/** Validates a `04` short-term or export plate (the export serial opens with no reserved pair) + expiry date. */
class GermanDatedPlateValidator : GatedPlateValidator() {
    override val gateGroup = "expiryDay"

    override fun judge(entry: PlateEntry): PlateValidation {
        val district = entry.group("district").uppercase()
        val serial = entry.group("serial")
        districtAndSerialError(district, serial)?.let { return it }
        val prefix = if (entry.spec.id == "de.export") null else "04"
        if (prefix != null && !opensWith(prefix, serial)) return PlateValidation.invalid("This number begins \"$prefix\".")
        if (serial.length > 5) return PlateValidation.invalid("The number is five digits.")
        return validateExpiry(entry.group("expiryDay"), entry.group("expiryMonth"), entry.group("expiryYear"))
    }

    companion object {
        /** DD/MM/YY on the band. Quiet on incomplete fields; February has 29 days (ambiguous century). */
        fun validateExpiry(day: String, month: String, year: String): PlateValidation {
            for ((name, value) in listOf("day" to day, "month" to month, "year" to year)) {
                if (value.length < 2) continue
                if (!isDigitsOfLength(value, 2)) return PlateValidation.invalid("The expiry $name is two digits.")
            }
            if (month.length == 2 && isDigits(month)) {
                val m = month.toInt()
                if (m < 1 || m > 12) return PlateValidation.invalid("\"$month\" is not a month.")
                if (day.length == 2 && isDigits(day)) {
                    val d = day.toInt()
                    if (d < 1 || d > daysInMonth[m - 1]) return PlateValidation.invalid("\"$day\" is not a day of month $month.")
                }
            } else if (day.length == 2 && isDigits(day)) {
                val d = day.toInt()
                if (d < 1 || d > 31) return PlateValidation.invalid("\"$day\" is not a day.")
            }
            return PlateValidation.valid
        }
    }
}

/** Validates a Bundeswehr `Y` plate: `Y` in the area code, then six digits. */
class GermanBundeswehrValidator : GatedPlateValidator() {
    override val gateGroup = "serialTail"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("district").uppercase() != "Y") return PlateValidation.invalid("A Bundeswehr plate begins \"Y\".")
        val serial = entry.group("serial") + entry.group("serialTail")
        if (!isDigits(serial)) return PlateValidation.invalid("The number must be digits.")
        if (serial.length > 6) return PlateValidation.invalid("The number is six digits.")
        return PlateValidation.valid
    }
}

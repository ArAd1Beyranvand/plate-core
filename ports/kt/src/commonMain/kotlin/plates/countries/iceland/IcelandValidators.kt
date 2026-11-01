package plates.countries.iceland

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

/** The third character of a diplomatic plate, by mission. From the article's table; `Q` is unassigned. */
object IcelandMissions {
    val names = mapOf(
        "A" to "United States",
        "B" to "United Kingdom",
        "C" to "Denmark",
        "D" to "Finland",
        "E" to "France",
        "F" to "India",
        "G" to "China",
        "H" to "Norway",
        "I" to "Poland",
        "J" to "Russia",
        "K" to "Sweden",
        "L" to "Czech Republic",
        "M" to "Canada",
        "N" to "Germany",
        "O" to "International Monetary Fund",
        "P" to "Japan",
        "R" to "European Union",
        "S" to "North Atlantic Treaty Organisation",
        "T" to "Spain",
    )
}

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters2 = Regex("^[A-Z]{2}$")
private val threeDigits = Regex("^[0-9]{3}$")
private val letterTwoDigits = Regex("^[A-Z][0-9]{2}$")

/** Judges a two-field plate: two letters and `123` or `C12`; `CD` takes the mission letter and two digits; `RN` takes three digits. Reports, never bars a keystroke. */
class IcelandValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val letters = entry.group("letters")
        val serial = entry.group("serial")
        if (!letters2.matches(letters)) return PlateValidation.invalid(REASON_LETTERS)
        if (letters == "CD") {
            if (!letterTwoDigits.matches(serial) || serial.substring(0, 1) !in IcelandMissions.names) {
                return PlateValidation.invalid(REASON_MISSION)
            }
        } else if (letters == "RN") {
            if (!threeDigits.matches(serial)) return PlateValidation.invalid(REASON_DEALER)
        } else if (!threeDigits.matches(serial) && !letterTwoDigits.matches(serial)) {
            return PlateValidation.invalid(REASON_SERIAL)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The prefix is two letters."
        const val REASON_SERIAL = "The second field is three digits or a letter and two digits."
        const val REASON_MISSION = "A diplomatic plate is CD, a mission letter and two digits."
        const val REASON_DEALER = "A dealer plate is RN and three digits."
    }
}

/** Judges a vanity plate: two to six characters that do not follow a standard format (`AB123`, `ABC12`). */
class IcelandVanityValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val value = entry.group("serial")
        if (value.length < 2 || value.length > 6) return PlateValidation.invalid(REASON_LENGTH)
        if (standard.matches(value)) return PlateValidation.invalid(REASON_STANDARD)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LENGTH = "A vanity plate is two to six characters."
        const val REASON_STANDARD = "A vanity plate must not follow the standard format."
        private val standard = Regex("^[A-Z]{2}([0-9]{3}|[A-Z][0-9]{2})$")
    }
}

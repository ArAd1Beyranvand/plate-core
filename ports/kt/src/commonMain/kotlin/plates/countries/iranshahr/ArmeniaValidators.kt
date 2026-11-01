package plates.countries.iranshahr

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

private val busClasses = listOf("S", "L")
private val diplomaticClasses = listOf("D", "T")
private val militaryClasses = listOf("M", "T")
private val stateVehiclesOnly = listOf('G', 'I')

// Every 01-99 is allocated, so a two-digit code other than 00 is issued.
private fun isIssuedRegion(code: String) = code != "00"

private fun tails(from: Int, to: Int) = (from..to).map { it.toString().padStart(2, '0') }.toSet()

// Latin letters of the combinations the state issues, with the tails each takes (null: any).
private val specialPlates = listOf(
    "OS" to setOf("01"),
    "UU" to setOf("01"),
    "OO" to tails(1, 11),
    "FF" to setOf("01"),
    "LL" to setOf("03", "50", "55", "60", "70"),
    "SS" to setOf("03", "60"),
    "VV" to setOf("01"),
    "NN" to setOf("01"),
    "GG" to setOf("01"),
    "II" to null,
    "SL" to tails(1, 33),
    "SS" to setOf("01"),
    "SS" to setOf("02"),
)

private fun isSpecialPlate(letters: String, tail: String) =
    specialPlates.any { (l, t) -> l == letters.uppercase() && (t == null || tail in t) }

// Month a letter first appeared, as year * 12 + month; L, U, S, O date from 1996.
private val introduced = mapOf(
    'L' to (1996 to 1), 'U' to (1996 to 1), 'S' to (1996 to 1), 'O' to (1996 to 1),
    'P' to (2008 to 12),
    'D' to (2012 to 7), 'N' to (2012 to 7), 'T' to (2012 to 7), 'V' to (2012 to 7),
    'A' to (2012 to 5), 'M' to (2012 to 5), 'Q' to (2012 to 5), 'R' to (2012 to 5),
    'C' to (2013 to 10), 'F' to (2013 to 10), 'Z' to (2013 to 10),
    'G' to (2015 to 1), 'I' to (2015 to 1),
    'X' to (2016 to 1),
    'B' to (2017 to 1), 'H' to (2017 to 1),
    'J' to (2018 to 1),
    'W' to (2019 to 1), 'Y' to (2019 to 1), 'K' to (2019 to 1), 'E' to (2019 to 1),
)

private fun inUseOn(letter: Char, year: Int, month: Int): Boolean {
    val (y, m) = introduced[letter.uppercaseChar()] ?: return false
    return year > y || (year == y && month >= m)
}

/**
 * Validates a private registration, `NN LL NNN`: a region code Armenia issues, letters that are neither `G` nor `I`
 * (reserved to the state since 2015) and a three-digit serial. Given [issuedYear], also checks the letters existed then.
 */
class ArmeniaPlateValidator(val issuedYear: Int? = null, val issuedMonth: Int = 12) : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val region = validateRegion(entry.group("region"))
        if (!region.isValid) return region
        val letters = validateLetters(entry.group("letters"), 2, issuedYear, issuedMonth)
        if (!letters.isValid) return letters
        return validateSerial(entry.group("serial"), 3)
    }

    companion object {
        /** Quiet until the code is two digits. */
        fun validateRegion(region: String): PlateValidation {
            if (region.length < 2) return PlateValidation.valid
            if (!isDigitsOfLength(region, 2)) return PlateValidation.invalid("A region code is two digits.")
            if (!isIssuedRegion(region)) return PlateValidation.invalid("\"$region\" is not a region code Armenia issues.")
            return PlateValidation.valid
        }

        /** [count] letters, none reserved to the state, none added after [issuedYear]. */
        fun validateLetters(letters: String, count: Int, issuedYear: Int? = null, issuedMonth: Int = 12): PlateValidation {
            val value = letters.uppercase()
            for (letter in value) {
                if (letter !in 'A'..'Z') return PlateValidation.invalid("\"$letter\" is not a plate letter.")
                if (letter in stateVehiclesOnly) {
                    return PlateValidation.invalid("\"$letter\" is issued to the Police and the Prosecutor's office only.")
                }
                if (issuedYear != null && !inUseOn(letter, issuedYear, issuedMonth)) {
                    return PlateValidation.invalid("\"$letter\" was not being issued in $issuedYear.")
                }
            }
            // Last, so a block still being typed is not flagged for its length.
            if (value.length > count) return PlateValidation.invalid("The letter block is $count letter(s).")
            return PlateValidation.valid
        }

        /** Quiet while short; leading zeros are legal. */
        fun validateSerial(serial: String, length: Int): PlateValidation {
            if (serial.isNotEmpty() && !isDigits(serial)) return PlateValidation.invalid("The serial must be digits.")
            if (serial.length > length) return PlateValidation.invalid("The serial is $length digits.")
            return PlateValidation.valid
        }
    }
}

/** Validates a state number, `NNN LL NN`, whose `LL NN` tail must be a combination issued to an institution. */
class ArmeniaPublicPlateValidator : GatedPlateValidator() {
    override val gateGroup = "tail"

    override fun judge(entry: PlateEntry): PlateValidation {
        val serial = ArmeniaPlateValidator.validateSerial(entry.group("serial"), 3)
        if (!serial.isValid) return serial
        val letters = entry.group("letters").uppercase()
        val tail = entry.group("tail")
        // Quiet until both halves are complete.
        if (letters.length < 2 || tail.length < 2) return PlateValidation.valid
        if (!isDigitsOfLength(tail, 2)) return PlateValidation.invalid("The last group is two digits.")
        if (!isSpecialPlate(letters, tail)) {
            return PlateValidation.invalid("\"$letters $tail\" is not a combination issued to any institution.")
        }
        return PlateValidation.valid
    }
}

/** Validates a trailer number, `NNN L` over `NN`. */
class ArmeniaTrailerPlateValidator : GatedPlateValidator() {
    override val gateGroup = "tail"

    override fun judge(entry: PlateEntry): PlateValidation {
        val serial = ArmeniaPlateValidator.validateSerial(entry.group("serial"), 3)
        if (!serial.isValid) return serial
        val letters = ArmeniaPlateValidator.validateLetters(entry.group("letters"), 1)
        if (!letters.isValid) return letters
        val tail = entry.group("tail")
        if (tail.isNotEmpty() && !isDigits(tail)) return PlateValidation.invalid("The bottom row must be digits.")
        if (tail.length > 2) return PlateValidation.invalid("The bottom row is two digits.")
        return PlateValidation.valid
    }
}

/** Validates a bus number, `NNNN L`. */
class ArmeniaBusPlateValidator : GatedPlateValidator() {
    override val gateGroup = "class"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("serial"), 4)) return PlateValidation.invalid("A bus number is four digits.")
        if (entry.group("class").uppercase() !in busClasses) {
            return PlateValidation.invalid("A bus is \"S\" (city) or \"L\" (long-range).")
        }
        return PlateValidation.valid
    }
}

/** Validates a diplomatic number, `NN L NNN`; the mission code is not checked, the class letter is `D` or `T`. */
class ArmeniaDiplomaticPlateValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val mission = entry.group("mission")
        if (mission.length == 2 && !isDigitsOfLength(mission, 2)) return PlateValidation.invalid("A mission code is two digits.")
        if (entry.group("class").uppercase() !in diplomaticClasses) {
            return PlateValidation.invalid("A diplomatic plate is \"D\" (diplomat) or \"T\" (technician).")
        }
        return ArmeniaPlateValidator.validateSerial(entry.group("serial"), 3)
    }
}

/** Validates a Ministry of Defence number, `ՊՆ NNNN Մ`; the class `Մ` or `Տ` is stored as `M` and `T`. */
class ArmeniaMilitaryPlateValidator : GatedPlateValidator() {
    override val gateGroup = "class"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("serial"), 4)) return PlateValidation.invalid("A military number is four digits.")
        if (entry.group("class").uppercase() !in militaryClasses) {
            return PlateValidation.invalid("A military plate is \"Մ\" (passenger) or \"Տ\" (transport).")
        }
        return PlateValidation.valid
    }
}

/** Validates the UN plate, whose only typed field is the serial. */
class ArmeniaSerialPlateValidator(val length: Int) : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry) = ArmeniaPlateValidator.validateSerial(entry.group("serial"), length)
}

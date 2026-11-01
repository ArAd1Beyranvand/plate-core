package plates.countries.iranshahr

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

private val regionCodes = setOf("01", "05", "02", "06", "03", "04", "07", "08")
private val plateLetters = "ABCDEHJKMOPTXYZ".toSet()
private val diplomaticClasses = listOf("CD", "CMD", "D", "T", "S")

/**
 * Validates a standard Tajik registration: a serial, a letter group and a two-digit region code, keyed by group name.
 * Variation between plates is data: [serialLength], [letterCount] (0 when there is no letter group), [checkRegion] and [gate].
 */
class TajikistanPlateValidator(
    val serialLength: Int = 4,
    val letterCount: Int = 2,
    val checkRegion: Boolean = true,
    val gate: String = "region",
) : GatedPlateValidator() {
    override val gateGroup = gate

    override fun judge(entry: PlateEntry): PlateValidation {
        if (checkRegion) {
            val region = validateRegion(entry.group("region"))
            if (!region.isValid) return region
        }
        if (letterCount > 0) {
            val letters = validateLetters(entry.group("letters"), letterCount)
            if (!letters.isValid) return letters
        }
        return validateSerial(entry.group("serial"), serialLength)
    }

    companion object {
        /** Quiet about a code that is not yet two digits. */
        fun validateRegion(region: String): PlateValidation {
            if (region.length < 2) return PlateValidation.valid
            if (!isDigitsOfLength(region, 2)) return PlateValidation.invalid("A region code is two digits.")
            if (region !in regionCodes) return PlateValidation.invalid("\"$region\" is not a region code Tajikistan issues.")
            return PlateValidation.valid
        }

        /** [count] plate letters; the length is checked last so a group still being typed is not flagged. */
        fun validateLetters(letters: String, count: Int): PlateValidation {
            val value = letters.uppercase()
            for (letter in value) {
                if (letter !in plateLetters) return PlateValidation.invalid("\"$letter\" is not a plate letter.")
            }
            if (value.length > count) return PlateValidation.invalid("The letter group is $count letter(s).")
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

/** Validates a Tajik foreign-vehicle number, `NNN L NNN`; no region code, each group judged on its shape. */
class TajikistanForeignPlateValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val prefix = TajikistanPlateValidator.validateSerial(entry.group("prefix"), 3)
        if (!prefix.isValid) return prefix
        val letter = TajikistanPlateValidator.validateLetters(entry.group("letters"), 1)
        if (!letter.isValid) return letter
        return TajikistanPlateValidator.validateSerial(entry.group("serial"), 3)
    }
}

/** Validates a Tajik diplomatic number, `NNN [class] N`: CD, CMD, D, T or S, and a single trailing digit. */
class TajikistanDiplomaticPlateValidator : GatedPlateValidator() {
    override val gateGroup = "tail"

    override fun judge(entry: PlateEntry): PlateValidation {
        val serial = TajikistanPlateValidator.validateSerial(entry.group("serial"), 3)
        if (!serial.isValid) return serial
        val code = entry.group("class").uppercase()
        if (code.isNotEmpty() && code !in diplomaticClasses) {
            return PlateValidation.invalid("A diplomatic class is CD, CMD, D, T or S.")
        }
        val tail = entry.group("tail")
        if (tail.isNotEmpty() && !isDigits(tail)) return PlateValidation.invalid("The trailing group must be digits.")
        if (tail.length > 1) return PlateValidation.invalid("The trailing group is one digit.")
        return PlateValidation.valid
    }
}

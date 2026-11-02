package plates.countries.cuba

import plates.core.alphabet.AlphabetInput
import plates.core.alphabet.PlateAlphabet
import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

// The issued series letters: I, O, Q, S, W and Z are not issued.
private val letters = PlateAlphabet.pattern(id = "cu.letters", include = "A-Y", exclude = "I O Q S W", input = AlphabetInput.typed, isNumeric = false)

/** Judges a 2013 Cuban plate value: the letter is an issued series and the serial fills every cell. Reports, never bars a keystroke. */
class CubaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val letter = entry.group("letter")
        if (letter.isEmpty()) return PlateValidation.invalid(REASON_LETTER_MISSING)
        if (!letters.accepts(letter)) return PlateValidation.invalid(REASON_LETTER_UNISSUED)
        val serial = entry.group("serial") + entry.group("serial2")
        if (serial.length != entry.spec.slotCount - 1) return PlateValidation.invalid(REASON_SERIAL_LENGTH)
        if (!isDigits(serial)) return PlateValidation.invalid(REASON_SERIAL_NOT_NUMERIC)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTER_MISSING = "A plate starts with a letter."
        const val REASON_LETTER_UNISSUED = "I, O, Q, S, W and Z are not issued."
        const val REASON_SERIAL_NOT_NUMERIC = "The number is digits only."
        const val REASON_SERIAL_LENGTH = "The number fills every cell."
    }
}

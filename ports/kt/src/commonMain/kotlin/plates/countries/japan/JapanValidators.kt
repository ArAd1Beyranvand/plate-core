package plates.countries.japan

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isLetters

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val classCode = Regex("^[0-9]{2}[0-9A-Z]?$")
private val serialRe = Regex("^(・・|・[0-9]|[0-9]{2})[0-9]{2}$")

/** Judges a Japanese plate by its fields: car, two-wheeler, export (Roman letters) or diplomatic (five digits). Reports, never bars a keystroke. */
class JapanValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val serial = entry.group("serial")
        val office = entry.group("office")
        val kana = entry.group("kana")
        if (office.isEmpty()) {
            return if (isDigitsOfLength(serial, 5)) PlateValidation.valid else PlateValidation.invalid(REASON_DIPLOMATIC)
        }
        if (office[0] in 'A'..'Z' || office[0] in 'a'..'z') { // the alphabet canonicalises case
            return if (isLetters(office, 2, 3) && isLetters(kana, 1, 2) && isDigitsOfLength(serial, 4)) {
                PlateValidation.valid
            } else {
                PlateValidation.invalid(REASON_EXPORT)
            }
        }
        if (kana.isEmpty()) return PlateValidation.invalid(REASON_CAR)
        if (entry.spec.indicesOfGroup("class").isNotEmpty() && !classCode.matches(entry.group("class"))) {
            return PlateValidation.invalid(REASON_CLASS)
        }
        return if (serialRe.matches(serial)) PlateValidation.valid else PlateValidation.invalid(REASON_SERIAL)
    }

    companion object {
        const val REASON_CAR = "A plate is an office, a class code, a hiragana and a four-place serial."
        const val REASON_CLASS = "A class code is two digits, then a digit or a letter."
        const val REASON_SERIAL = "A serial is four places; leading zeros are printed as dots."
        const val REASON_EXPORT = "An export plate is two or three letters, one or two letters and four digits."
        const val REASON_DIPLOMATIC = "A diplomatic plate is five digits."
    }
}

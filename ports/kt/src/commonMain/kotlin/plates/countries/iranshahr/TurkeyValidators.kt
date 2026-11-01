package plates.countries.iranshahr

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength

// A-Z without Q, W, X.
private val plateLetters = ('A'..'Z').filter { it !in "QWX" }.toSet()

/**
 * What a Turkish registration may contain, as description rather than restriction. Province 01-81; one to three letters;
 * figures. With [limitSix], letters and figures together number at most six.
 */
class TurkeyPlateValidator(val limitSix: Boolean = true) : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        val province = entry.group("province")
        val letters = entry.group("letters")
        val serial = entry.group("serial")
        if (province.isNotEmpty() && !isProvince(province)) return PlateValidation.invalid("Province code must be 01 to 81")
        val hasLetters = entry.spec.indicesOfGroup("letters").isNotEmpty()
        if (hasLetters && letters.isNotEmpty() && !isLetters(letters)) {
            return PlateValidation.invalid("Letters exclude Ç Ş İ Ö Ü Ğ Q W X")
        }
        if (serial.isNotEmpty() && !isDigits(serial)) return PlateValidation.invalid("Serial must be figures")
        if (limitSix && hasLetters && letters.length + serial.length > MAX_LETTERS_AND_DIGITS) {
            return PlateValidation.invalid("Letters and figures number at most six")
        }
        return PlateValidation.valid
    }

    companion object {
        const val MAX_LETTERS_AND_DIGITS = 6

        fun isProvince(code: String) = isDigitsOfLength(code, 2) && code.toInt() in 1..81

        fun isLetters(letters: String) = letters.isNotEmpty() && letters.all { it in plateLetters }
    }
}

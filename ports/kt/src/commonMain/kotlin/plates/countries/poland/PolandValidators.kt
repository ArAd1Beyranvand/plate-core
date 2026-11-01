package plates.countries.poland

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength
import plates.core.validators.restrictionVerdict

// PolandMissions.all: every listed code; 049 and 095 are refused by the spec's restriction.
private val missionCodes = (
    "001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 018 019 020 021 022 " +
    "023 024 025 026 027 028 029 030 031 032 033 034 035 036 037 038 039 040 041 042 043 044 " +
    "045 046 047 048 050 051 052 053 054 055 056 057 058 059 060 061 062 063 064 065 066 067 " +
    "068 069 070 071 072 073 074 075 076 077 078 079 081 082 083 084 085 086 087 088 089 090 " +
    "091 092 093 094 096 097 098 099 100 101 102 103 104 105 106 107 108 109 110 111 112 113 " +
    "114 115 116 117 118 119 120 121"
    ).split(' ').toSet()

// PolandAlphabets.letters: A-Z without Q.
private fun isLetter(c: String) = c.length == 1 && c[0] in 'A'..'Z' && c[0] != 'Q'
private fun isLetter(c: Char) = isLetter(c.toString())
private fun letters(s: String) = s.all(::isLetter)

private fun voivodeshipDigit(code: String) = code.length == 2 && isLetter(code[0]) && isDigits(code.substring(1))

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val digitThenLetter = Regex("[0-9][A-Z]")
private val customShape = Regex("^[A-Z]+[0-9]{0,2}$")

/**
 * Judges a Polish plate, field by field. Reports, never bars a keystroke.
 *
 * A car or electric plate is a two- or three-letter county code and a series of five characters (four after a three-letter code), whose letters exclude B, D, I, O and Z. After a two-letter code the series starts with a digit, and after a three-letter one four characters may be neither all digits nor three digits and a letter. A custom plate has a letter and a digit, then three to five characters, a letter first, at most two digits at the end and no letter after a digit; any letter but Q is allowed.
 */
class PolandValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        fun g(key: String) = entry.group(key)
        val code = g("code")
        val serial = g("serial")
        var bad: String? = null
        when (entry.spec.id) {
            "pl.private" -> if (code.isNotEmpty() && serial.isNotEmpty()) bad = car(code, serial)
            "pl.custom" -> if (code.isNotEmpty() && serial.isNotEmpty()) bad = custom(code, serial)
            "pl.professional" -> if (code.isNotEmpty() && serial.isNotEmpty()) {
                if (!(code.length == 3 && isLetter(code[0]) && isDigits(code.substring(1)) &&
                        serial.length == 5 && isDigits(serial.substring(0, 2)) && serial[2] == 'P' &&
                        isDigits(serial.substring(3)))
                ) {
                    bad = REASON_PROFESSIONAL
                }
            }
            "pl.temporary" -> if (code.isNotEmpty() && serial.isNotEmpty()) {
                if (!voivodeshipDigit(code)) {
                    bad = REASON_VOIVODESHIP
                } else if (!(serial.length == 4 && isDigits(serial.substring(0, 3)) &&
                        (isDigits(serial.substring(3)) || isLetter(serial[3])))
                ) {
                    bad = REASON_TEMPORARY
                }
            }
            "pl.test" -> {
                val n = g("number")
                val s = g("suffix")
                if (code.isNotEmpty() && n.isNotEmpty() && s.isNotEmpty()) {
                    if (!voivodeshipDigit(code)) {
                        bad = REASON_VOIVODESHIP
                    } else if (!isDigitsOfLength(n, 3) || s != "B") {
                        bad = REASON_TEST
                    }
                }
            }
            "pl.classic" -> if (code.isNotEmpty() && serial.isNotEmpty()) {
                if (!(code.length + serial.length == 5 && letters(code))) bad = REASON_CLASSIC
            }
            "pl.motorcycle" -> if (code.isNotEmpty() && serial.isNotEmpty()) {
                if (!(code.length >= 2 && letters(code) && serial.length == 4)) bad = REASON_MOTORCYCLE
            }
            "pl.reduced" -> if (code.isNotEmpty() && serial.isNotEmpty()) {
                if (!(isLetter(code) && serial.length == 3)) bad = REASON_REDUCED
            }
            "pl.diplomatic" -> {
                val w = g("voivodeship")
                val m = g("mission")
                val s = g("serial")
                if (w.isNotEmpty() && w != "W") {
                    bad = REASON_DIPLOMATIC_LETTER
                } else if (m.length == 3 && m !in missionCodes) {
                    bad = REASON_MISSION
                } else if (s.isNotEmpty() && !isDigits(s)) {
                    bad = REASON_DIPLOMATIC_SERIAL
                }
            }
        }
        return if (bad == null) PlateValidation.valid else PlateValidation.invalid(bad)
    }

    private fun car(code: String, serial: String): String? {
        if (!(code.length >= 2 && letters(code))) return REASON_CODE
        if (serial.any { it in EXCLUDED }) return REASON_SERIES_LETTERS
        if (code.length == 2) return if (serial.length == 5 && isDigits(serial.substring(0, 1))) null else REASON_CAR_SERIES
        if (serial.length == 5) return null
        if (serial.length != 4) return REASON_CAR_SERIES
        val allDigits = isDigits(serial)
        val digitsThenLetter = isDigits(serial.substring(0, 3)) && isLetter(serial[3])
        return if (allDigits || digitsThenLetter) REASON_THREE_LETTER_SERIES else null
    }

    private fun custom(code: String, serial: String): String? {
        if (!voivodeshipDigit(code)) return REASON_VOIVODESHIP
        val shape = serial.length >= 3 && isLetter(serial[0]) &&
            !digitThenLetter.containsMatchIn(serial) && customShape.matches(serial)
        return if (shape) null else REASON_CUSTOM
    }

    companion object {
        const val REASON_CODE = "Two or three letters."
        const val REASON_SERIES_LETTERS = "B, D, I, O and Z are not used in a series."
        const val REASON_CAR_SERIES = "Five characters, the first a digit after a two-letter code."
        const val REASON_THREE_LETTER_SERIES =
            "Four characters after a three-letter code may not be digits only, or three digits and a letter."
        const val REASON_VOIVODESHIP = "A letter then a digit."
        const val REASON_CUSTOM =
            "Three to five characters: a letter first, letters before digits, at most two digits."
        const val REASON_PROFESSIONAL = "A letter and two digits, then two digits, P and two digits."
        const val REASON_TEMPORARY = "Four digits, or three and a letter."
        const val REASON_TEST = "Three digits, then the letter B."
        const val REASON_CLASSIC = "Two or three letters and two or three characters, five in all."
        const val REASON_MOTORCYCLE = "Two or three letters, then four."
        const val REASON_REDUCED = "A letter, then three characters."
        const val REASON_DIPLOMATIC_LETTER = "W is the only code issued."
        const val REASON_MISSION = "Not a listed mission code."
        const val REASON_DIPLOMATIC_SERIAL = "Three digits."

        private const val EXCLUDED = "BDIOZ"
    }
}

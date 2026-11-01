package plates.countries.thailand

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val leadDigit = Regex("^[1-9]$")
private val serial = Regex("^[1-9][0-9]{0,3}$")

// ThailandAlphabets.letters: thirty-nine Thai consonants.
private val thaiLetters = "ก ข ค ง จ ฉ ช ฌ ฏ ฐ ณ ด ต ถ ท ธ น บ ป ผ พ ฟ ภ ม ย ร ล ว ศ ษ ส ห ฬ อ ฮ ญ ฒ ฆ ซ".split(" ").toSet()

/** Judges by the registers the spec has: an optional leading digit, the series letters, and a serial of one to four digits without leading zeroes (bus and truck plates print two series digits and four serial digits). Reports, never bars a keystroke. */
class ThailandValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val spec = entry.spec
        val lead = entry.group("lead")
        if (spec.indicesOfGroup("lead").isNotEmpty() && lead.isNotEmpty() && !leadDigit.matches(lead)) {
            return PlateValidation.invalid(REASON_LEAD)
        }
        val letters = spec.indicesOfGroup("series").size
        if (letters > 0) {
            val series = entry.group("series").codePointsList()
            if (series.size != letters || !series.all { it in thaiLetters }) {
                return PlateValidation.invalid(REASON_SERIES)
            }
        }
        if (spec.indicesOfGroup("prefix").isNotEmpty()) {
            if (!isDigitsOfLength(entry.group("prefix"), 2)) return PlateValidation.invalid(REASON_PREFIX)
            if (!isDigitsOfLength(entry.group("serial"), 4)) return PlateValidation.invalid(REASON_TRUCK_SERIAL)
            val code = entry.group("code")
            if (code.isNotEmpty() && !isDigitsOfLength(code, 2)) return PlateValidation.invalid(REASON_CODE)
            return PlateValidation.valid
        }
        if (!serial.matches(entry.group("serial"))) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LEAD = "A leading digit is 1 to 9."
        const val REASON_SERIES = "The series is Thai consonants."
        const val REASON_PREFIX = "The series is two digits."
        const val REASON_SERIAL = "The number is 1 to 9999."
        const val REASON_TRUCK_SERIAL = "The number is four digits."
        const val REASON_CODE = "The province code is two digits."
    }
}

// Dart's `runes`: one string per code point, not per UTF-16 unit.
private fun String.codePointsList(): List<String> {
    val out = mutableListOf<String>()
    var i = 0
    while (i < length) {
        val n = if (this[i].isHighSurrogate() && i + 1 < length && this[i + 1].isLowSurrogate()) 2 else 1
        out.add(substring(i, i + n))
        i += n
    }
    return out
}

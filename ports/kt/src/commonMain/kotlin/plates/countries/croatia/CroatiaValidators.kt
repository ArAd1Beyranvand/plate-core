package plates.countries.croatia

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.isDigitsOfLength
import plates.core.validators.restrictionVerdict

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val classLetter = Regex("^[A-Z]$")
private val word = Regex("^[A-Z]{4,5}$")
private val suffix = Regex("^[0-9]{1,2}$")
private val number = Regex("^[0-9]{3,4}$")
private val letters = Regex("^[A-Z]{1,2}$")

private val regionCodes = setOf(
    "BJ", "BM", "ČK", "DA", "DE", "DJ", "DU", "GS", "IM", "KA", "KC", "KR",
    "KT", "KŽ", "MA", "NA", "NG", "OG", "OS", "PU", "PŽ", "RI", "SB", "SK",
    "SL", "ST", "ŠI", "VK", "VT", "VU", "VŽ", "ZD", "ZG", "ŽU",
)

/** Judges a Croatian plate by its groups: registration, customized, police or diplomatic. Reports, never bars a keystroke. */
class CroatiaValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        val groups = entry.spec.textGroups
        if (groups.isEmpty() || entry.group(groups.last().key ?: "").isEmpty()) return PlateValidation.valid
        return reason(entry)?.let { PlateValidation.invalid(it) } ?: PlateValidation.valid
    }

    private fun reason(e: PlateEntry): String? {
        val first = e.spec.textGroups.first().key
        if (first == "mission") {
            return if (isDigitsOfLength(e.group("mission"), 3) && classLetter.matches(e.group("class")) &&
                isDigitsOfLength(e.group("serial"), 3)
            ) null else REASON_DIPLOMATIC
        }
        if (first == "first") {
            return if (isDigitsOfLength(e.group("first"), 3) && isDigitsOfLength(e.group("second"), 3)) null else REASON_POLICE
        }
        if (e.group("region") !in regionCodes) return REASON_REGION
        if (e.spec.textGroups.any { it.key == "word" }) {
            if (!word.matches(e.group("word"))) return REASON_WORD
            return if (suffix.matches(e.group("suffix"))) null else REASON_SUFFIX
        }
        if (!number.matches(e.group("number"))) return REASON_NUMBER
        return if (letters.matches(e.group("letters"))) null else REASON_LETTERS
    }

    companion object {
        const val REASON_REGION = "The city code is two letters, e.g. ZG."
        const val REASON_NUMBER = "The number is three or four digits."
        const val REASON_LETTERS = "The series is one or two letters."
        const val REASON_WORD = "The word is four to five letters."
        const val REASON_SUFFIX = "The suffix is one or two digits."
        const val REASON_POLICE = "Police is three digits, three digits."
        const val REASON_DIPLOMATIC = "Diplomatic is three digits, a letter, three digits."
    }
}

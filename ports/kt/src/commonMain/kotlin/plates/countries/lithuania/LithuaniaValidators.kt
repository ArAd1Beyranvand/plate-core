package plates.countries.lithuania

import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.validators.isDigits
import plates.core.validators.isDigitsOfLength
import plates.core.validators.restrictionVerdict

// Mission codes the diplomatic list knows; 41 is refused by the spec's restriction, not listed.
private val missionCodes: Set<String> =
    (((1..16) + (18..26) + (28..34) + listOf(36, 37, 39, 40, 42, 43)).map { it.toString().padStart(2, '0') }).toSet()

// A-Z without Q, W and X.
private fun letters(value: String) = value.all { it in 'A'..'Z' && it != 'Q' && it != 'W' && it != 'X' }

private fun prefixed(prefix: String, number: String, expected: String, reason: String): String? {
    if (prefix.isEmpty() || number.isEmpty()) return null
    return if (prefix == expected && isDigitsOfLength(number, 5)) null else reason
}

/** Judges a Lithuanian plate, field by field. Reports, never bars a keystroke. */
class LithuaniaValidator : PlateValidator {
    override fun validate(entry: PlateEntry): PlateValidation {
        restrictionVerdict(entry)?.let { return it }
        fun g(key: String) = entry.group(key)
        var bad: String? = null
        when (entry.spec.id) {
            "lt.private" -> {
                val l = g("letters")
                val n = g("number")
                if (l.isEmpty() || n.isEmpty()) return PlateValidation.valid
                bad = if (!letters(l)) REASON_LETTERS else null
                if (bad == null && !(l.length == 3 && isDigitsOfLength(n, 3))) bad = REASON_REGULAR
            }
            "lt.taxi" -> bad = prefixed(g("prefix"), g("number"), "T", REASON_TAXI)
            "lt.dealer" -> bad = prefixed(g("prefix"), g("number"), "P", REASON_DEALER)
            "lt.temporary" -> {
                val n = g("number")
                val l = g("letters")
                if (n.isEmpty() || l.isEmpty()) return PlateValidation.valid
                if (!letters(l)) bad = REASON_LETTERS
                else if (!(isDigitsOfLength(n, 4) && l.length <= 2)) bad = REASON_TEMPORARY
            }
            "lt.military" -> {
                val c = g("code")
                val n = g("number")
                val l = g("letters")
                if (c.isEmpty() || n.isEmpty() || l.isEmpty()) return PlateValidation.valid
                if (c != "LK" || !isDigitsOfLength(n, 3) || !letters(l)) bad = REASON_MILITARY
            }
            "lt.agricultural" -> {
                val p = g("prefix")
                val n = g("number")
                val s = g("suffix")
                if (p.isEmpty() || n.isEmpty() || s.isEmpty()) return PlateValidation.valid
                if (!letters(p + s)) bad = REASON_LETTERS
                else if (!isDigits(n) || n.length < 3) bad = REASON_AGRICULTURAL
            }
            "lt.diplomatic" -> {
                val m = g("mission")
                val s = g("status")
                val n = g("serial")
                if (m.length == 2 && m !in missionCodes) bad = REASON_MISSION
                else if (s.isNotEmpty() && s !in "1234") bad = REASON_STATUS
                else if (n.isNotEmpty() && !(isDigits(n) && n.length >= 2)) bad = REASON_SERIAL
            }
        }
        return if (bad == null) PlateValidation.valid else PlateValidation.invalid(bad)
    }

    companion object {
        const val REASON_LETTERS = "Letters exclude Q, W and X."
        const val REASON_REGULAR = "Three letters then three digits."
        const val REASON_TAXI = "T then five digits."
        const val REASON_DEALER = "P then five digits."
        const val REASON_TEMPORARY = "Four digits then one or two letters."
        const val REASON_MILITARY = "LK, three digits, then a letter."
        const val REASON_AGRICULTURAL = "A letter, three or four digits, then a letter."
        const val REASON_MISSION = "Not a listed mission code."
        const val REASON_STATUS = "The status digit is 1 to 4."
        const val REASON_SERIAL = "Two or three digits."
    }
}

package plates.countries.serbia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength
import plates.core.validators.restrictionVerdict

// SerbiaAlphabets.regionLetters (A-C Ć Č D-S Š T-V Z Ž minus F H Q) and .letters (A-Z minus Q W Y), inlined.
private val regionLetters: Set<Char> =
    (('A'..'C') + 'Ć' + 'Č' + ('D'..'S') + 'Š' + ('T'..'V') + 'Z' + 'Ž').filter { it != 'F' && it != 'H' && it != 'Q' }.toSet()
private val serialLetters: Set<Char> = ('A'..'Z').filter { it != 'Q' && it != 'W' && it != 'Y' }.toSet()

private fun inAlphabet(v: String, n: Int, alphabet: Set<Char>) = v.length == n && v.all { it in alphabet }

private fun letters(v: String, n: Int) = inAlphabet(v, n, serialLetters)

private fun ok(ok: Boolean, reason: String) = if (ok) PlateValidation.valid else PlateValidation.invalid(reason)

/** Judges a Serbian plate by its keyed groups; which groups exist depends on the design, read off the spec id. */
class SerbiaValidator : GatedPlateValidator() {
    override val gateGroup = "region"

    override fun validate(entry: PlateEntry): PlateValidation {
        val id = entry.spec.id
        if (id == "rs.police" || id == "rs.military" || id == "rs.diplomatic") {
            return restrictionVerdict(entry) ?: judgeSpecial(entry, id)
        }
        return super.validate(entry)
    }

    private fun judgeSpecial(entry: PlateEntry, id: String): PlateValidation = when (id) {
        "rs.police" -> ok(
            isDigitsOfLength(entry.group("a"), 3) && isDigitsOfLength(entry.group("b"), 3),
            REASON_DIGITS,
        )
        "rs.military" -> ok(
            letters(entry.group("letter"), 1) && isDigitsOfLength(entry.group("digits"), 4),
            REASON_DIGITS,
        )
        else -> ok(
            isDigitsOfLength(entry.group("code"), 2) &&
                isDigitsOfLength(entry.group("serial"), 3) &&
                (entry.group("tail").isEmpty() || isDigitsOfLength(entry.group("tail"), 2)),
            REASON_DIGITS,
        )
    }

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!inAlphabet(entry.group("region"), 2, regionLetters)) return PlateValidation.invalid(REASON_REGION)
        return when (entry.spec.id) {
            "rs.private" -> {
                val d = entry.group("digits")
                ok((isDigitsOfLength(d, 3) || isDigitsOfLength(d, 4)) && letters(entry.group("letters"), 2), REASON_DIGITS)
            }
            "rs.taxi" -> ok(isDigitsOfLength(entry.group("digits"), 5), REASON_DIGITS)
            "rs.trailer" -> ok(
                letters(entry.group("letters"), 2) && isDigitsOfLength(entry.group("digits"), 3),
                REASON_DIGITS,
            )
            "rs.oldtimer" -> ok(entry.group("a") == "OT" && isDigitsOfLength(entry.group("b"), 3), REASON_DIGITS)
            "rs.agricultural" -> ok(
                isDigitsOfLength(entry.group("a"), 2) && letters(entry.group("b"), 3),
                REASON_LETTERS,
            )
            else -> ok(isDigitsOfLength(entry.group("a"), 2) && isDigitsOfLength(entry.group("b"), 3), REASON_DIGITS)
        }
    }

    companion object {
        const val REASON_REGION = "The area code is two letters, e.g. BG."
        const val REASON_DIGITS = "Check the number of digits."
        const val REASON_LETTERS = "Check the series letters."
    }
}

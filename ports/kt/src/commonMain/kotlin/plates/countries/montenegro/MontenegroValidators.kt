package plates.countries.montenegro

import plates.core.validators.*

// MontenegroAlphabets.letters / diplomaticLetters / mixed.
private val letterSet = ('A'..'Z').filter { it != 'I' && it != 'O' }.toSet()
private val diplomaticLetters = setOf('A', 'C', 'E', 'M', 'P')
private val mixedSet = letterSet + ('0'..'9')

private val municipalities = listOf(
    "AN", "BA", "BD", "BP", "BR", "CT", "DG", "GS", "HN", "KL", "KO", "MK",
    "NK", "PG", "PL", "PT", "PŽ", "PV", "RO", "ŠN", "TV", "TZ", "UL", "ZT",
    "ŽB",
)

private fun isIn(alphabet: Set<Char>, v: String, n: Int) = v.length == n && v.all { it in alphabet }

private fun ok(ok: Boolean, reason: String) = if (ok) PlateValidation.valid else PlateValidation.invalid(reason)

/**
 * Judges a Montenegrin plate by its keyed groups; which groups exist depends on the design, read off the spec id.
 * Reports, never bars a keystroke.
 *
 * - `me.regular`: `region` (a municipal code), `letters` (two, no `I` or `O`) and `serial` (three digits).
 * - `me.diplomatic`: `code` (two or three digits), `letter` (`A`, `M`, `P`, `E` or `C`) and `serial` (three digits).
 * - `me.temporary`: `region`, `year` (two digits) and `serial` (three).
 * - `me.agricultural`: `region`, `letters` (two) and `serial` (two digits).
 * - `me.moped`: `region` and `serial` (four letters or digits).
 */
class MontenegroValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val id = entry.spec.id
        if (id == "me.diplomatic") {
            val code = entry.group("code")
            return ok(
                (isDigitsOfLength(code, 2) || isDigitsOfLength(code, 3)) &&
                    isIn(diplomaticLetters, entry.group("letter"), 1) &&
                    isDigitsOfLength(entry.group("serial"), 3),
                REASON_DIGITS,
            )
        }
        if (entry.group("region") !in municipalities) return PlateValidation.invalid(REASON_REGION)
        val serial = entry.group("serial")
        return when (id) {
            "me.regular" -> ok(isIn(letterSet, entry.group("letters"), 2) && isDigitsOfLength(serial, 3), REASON_LETTERS)
            "me.temporary" -> ok(isDigitsOfLength(entry.group("year"), 2) && isDigitsOfLength(serial, 3), REASON_DIGITS)
            "me.agricultural" -> ok(isIn(letterSet, entry.group("letters"), 2) && isDigitsOfLength(serial, 2), REASON_LETTERS)
            else -> ok(isIn(mixedSet, serial, 4), REASON_DIGITS)
        }
    }

    companion object {
        const val REASON_REGION = "The municipal code is two letters, e.g. PG."
        const val REASON_DIGITS = "Check the number of digits."
        const val REASON_LETTERS = "Check the series letters."
    }
}

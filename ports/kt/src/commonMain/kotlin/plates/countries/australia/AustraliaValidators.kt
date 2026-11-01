package plates.countries.australia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

private const val LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
private const val DIGITS = "0123456789"

/**
 * One field of a plate, in the article's own notation: one shape character per position. `a` any letter, `n` any digit, `z` a digit 1-9, `x` a letter other than I and O, `m` a letter or a digit; any other character is that literal. [min] is the fewest characters when the field is variable.
 */
private class AustraliaField(val shape: String, min: Int? = null) {
    val minLength = min ?: shape.length

    private fun matches(s: Char, c: Char) = when (s) {
        'a' -> c in LETTERS
        'x' -> c in LETTERS && c != 'I' && c != 'O'
        'n' -> c in DIGITS
        'z' -> c in DIGITS && c != '0'
        'm' -> c in LETTERS || c in DIGITS
        else -> c == s
    }

    /** Whether [value] is a whole, legal field. */
    fun accepts(value: String): Boolean {
        if (value.length < minLength || value.length > shape.length) return false
        return value.indices.all { matches(shape[it], value[it]) }
    }
}

private fun fields(vararg f: Any) = f.map { if (it is AustraliaField) it else AustraliaField(it as String) }

/** The fields of each design, in print order, by spec id. */
private val bySpecId = mapOf(
    "au.nsw" to fields("aa", "nn", "xa"),
    "au.nt" to fields("Ca", "nn", "aa"),
    "au.federalInterstate" to fields("aa", "nn", "aa"),
    "au.act" to fields("Yaa", "nna"),
    "au.qld" to fields("nnn", "mmm"),
    "au.sa" to fields("Snnn", "aaa"),
    "au.tas" to fields("a", "nn", "aa"),
    "au.vic" to fields("zaa", "zaa"),
    "au.wa" to fields("zaaa", "nnn"),
    "au.nationalHeavyVehicle" to fields("aa", "nnaa"),
    "au.army" to fields("nn", AustraliaField("nnnn", min = 3)),
    "au.airForce" to fields("nnnnnn"),
    "au.defence" to fields("a", "mmmmm"),
    "au.diplomatic" to fields("Da", AustraliaField("nnnnn", min = 4)),
)

/**
 * Judges an Australian plate against its design's formats. Reports, never bars a keystroke.
 *
 * Quiet until the first field has a character. Each field must then be whole and match its shape (the NSW suffix skips `I` and `O`; WA and VIC skip a leading 0). The jurisdictions have different formats, so the spec's id picks them; an unknown spec is valid.
 */
class AustraliaValidator : GatedPlateValidator() {
    override val gateGroup = "f0"

    override fun judge(entry: PlateEntry): PlateValidation {
        val fields = bySpecId[entry.spec.id] ?: return PlateValidation.valid
        for ((i, field) in fields.withIndex()) {
            if (!field.accepts(entry.group("f$i"))) return PlateValidation.invalid(REASON_FIELD)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_FIELD = "A field does not fit this plate's format."
    }
}

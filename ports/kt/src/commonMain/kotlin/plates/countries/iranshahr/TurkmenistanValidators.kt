package plates.countries.iranshahr

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation

private val provinceCodes = listOf("AG", "AH", "AK", "BN", "DZ", "LB", "MR")

/** One register of a Turkmen serial: [length] digits or Latin capitals, and when [allowed] is set, one of those values. */
class TurkmenistanPart(val group: String, val length: Int, val digits: Boolean = false, val allowed: List<String>? = null) {
    // H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
    private val pattern = Regex("^${if (digits) "[0-9]" else "[A-Z]"}{$length}$")

    fun accepts(value: String) = pattern.matches(value) && (allowed == null || value in allowed)

    val reason: String
        get() = if (allowed != null) "The $group is one of ${allowed.joinToString(", ")}."
        else "The $group is $length ${if (digits) "digits" else "letters"}."
}

/** Judges a Turkmen serial register by register; the default is the private plate `AT 0123 AG`. Reports, never bars a keystroke. */
class TurkmenistanValidator(val parts: List<TurkmenistanPart> = private) : GatedPlateValidator() {
    override val gateGroup get() = parts.last().group

    override fun judge(entry: PlateEntry): PlateValidation {
        for (part in parts) {
            if (!part.accepts(entry.group(part.group))) return PlateValidation.invalid(part.reason)
        }
        return PlateValidation.valid
    }

    companion object {
        private val province = TurkmenistanPart("region", 2, allowed = provinceCodes)
        private val private = listOf(TurkmenistanPart("series", 2), TurkmenistanPart("number", 4, digits = true), province)

        val classic get() = TurkmenistanValidator(
            listOf(TurkmenistanPart("series", 1), TurkmenistanPart("first", 2, digits = true), TurkmenistanPart("second", 2, digits = true), province),
        )
        val trailer get() = TurkmenistanValidator(
            listOf(TurkmenistanPart("series", 2), TurkmenistanPart("number", 4, digits = true), TurkmenistanPart("letters", 2)),
        )
        val foreign get() = TurkmenistanValidator(
            listOf(TurkmenistanPart("class", 1, digits = true), TurkmenistanPart("letter", 1, allowed = listOf("H")), TurkmenistanPart("number", 5, digits = true)),
        )
        val foreignTrailer get() = TurkmenistanValidator(
            listOf(TurkmenistanPart("class", 1, digits = true), TurkmenistanPart("letters", 2, allowed = listOf("HT")), TurkmenistanPart("number", 4, digits = true)),
        )
        val export get() = TurkmenistanValidator(listOf(TurkmenistanPart("letters", 3), TurkmenistanPart("number", 4, digits = true)))
        val diplomatic get() = TurkmenistanValidator(
            listOf(TurkmenistanPart("embassy", 2, digits = true), TurkmenistanPart("letters", 2, allowed = listOf("CD")), TurkmenistanPart("number", 3, digits = true)),
        )
        val government get() = TurkmenistanValidator(listOf(TurkmenistanPart("number", 4, digits = true), TurkmenistanPart("letters", 3)))
        val military get() = TurkmenistanValidator(listOf(TurkmenistanPart("number", 4, digits = true), TurkmenistanPart("letters", 2)))
        val ceremony get() = TurkmenistanValidator(listOf(TurkmenistanPart("letters", 6), TurkmenistanPart("number", 1, digits = true)))
    }
}

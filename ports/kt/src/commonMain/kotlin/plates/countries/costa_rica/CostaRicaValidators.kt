package plates.countries.costa_rica

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

// H9: explicit ASCII class, portable across JVM/JS/Wasm regex engines.
private val upperLetters = Regex("^[A-Z]+$")

/** One field of a plate: the text group it is read from, whether it is letters or digits, and how many characters it holds. */
class CostaRicaField(val key: String, val name: String, val letters: Boolean = false, val min: Int, val max: Int) {
    fun accepts(value: String): Boolean {
        if (value.length < min || value.length > max) return false
        return if (letters) upperLetters.matches(value) else isDigits(value)
    }

    val reason: String
        get() {
            val kind = if (letters) "letters" else "digits"
            return if (min == max) "The $name is $max $kind." else "The $name is $min to $max $kind."
        }
}

/** The fields of one design, in print order. */
class CostaRicaFormat(val fields: List<CostaRicaField>) {
    companion object {
        val private = CostaRicaFormat(
            listOf(CostaRicaField("letters", "series", letters = true, min = 3, max = 3), CostaRicaField("number", "number", min = 3, max = 3)),
        )
        val disabled = CostaRicaFormat(listOf(CostaRicaField("number", "number", min = 3, max = 4)))
        val bus = CostaRicaFormat(listOf(CostaRicaField("number", "number", min = 4, max = 5)))
        val commercial = CostaRicaFormat(listOf(CostaRicaField("number", "number", min = 6, max = 6)))
        val protocol = CostaRicaFormat(listOf(CostaRicaField("code", "code", min = 2, max = 2), CostaRicaField("number", "number", min = 3, max = 3)))
        val powerExecutive = CostaRicaFormat(listOf(CostaRicaField("code", "code", min = 2, max = 2), CostaRicaField("number", "number", min = 4, max = 4)))
        val consular = CostaRicaFormat(
            listOf(CostaRicaField("unit", "first number", min = 1, max = 1), CostaRicaField("number", "second number", min = 2, max = 2)),
        )
        val official = CostaRicaFormat(
            listOf(CostaRicaField("unit", "first number", min = 2, max = 2), CostaRicaField("number", "second number", min = 4, max = 4)),
        )
        val historical = CostaRicaFormat(listOf(CostaRicaField("number", "number", min = 2, max = 4)))
    }
}

/** Judges a Costa Rican value against a [CostaRicaFormat]. Reports, never bars a keystroke. */
class CostaRicaValidator(val format: CostaRicaFormat = CostaRicaFormat.private) : GatedPlateValidator() {
    override val gateGroup = format.fields.last().key

    override fun judge(entry: PlateEntry): PlateValidation {
        for (field in format.fields) {
            if (!field.accepts(entry.group(field.key))) return PlateValidation.invalid(field.reason)
        }
        return PlateValidation.valid
    }
}

package plates.countries.egypt

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// EgyptAlphabets.letters, inlined.
private const val PLATE_LETTERS = "ABGDRSCTEFKLMNHWY"

/** Judges a plate by the length of each register; `digits` and `code` are numerals, any other group is plate letters. */
class EgyptValidator(val lengths: Map<String, Int>) : GatedPlateValidator() {
    override val gateGroup = "digits"

    override fun judge(entry: PlateEntry): PlateValidation {
        for ((key, length) in lengths) {
            val value = entry.group(key)
            val ok = if (key == "letters") value.length == length && value.all { it in PLATE_LETTERS }
            else isDigitsOfLength(value, length)
            if (!ok) return PlateValidation.invalid(reasonFor(key, length))
        }
        return PlateValidation.valid
    }

    companion object {
        val car = EgyptValidator(mapOf("digits" to 4, "letters" to 3))
        val cairo = EgyptValidator(mapOf("digits" to 3, "letters" to 3))
        val giza = EgyptValidator(mapOf("digits" to 4, "letters" to 2))
        val diplomatic = EgyptValidator(mapOf("digits" to 3, "code" to 2))
        val police = EgyptValidator(mapOf("digits" to 4, "code" to 2, "letters" to 1))
        val motorcycle = EgyptValidator(mapOf("letters" to 3, "digits" to 4))

        fun reasonFor(group: String, length: Int) =
            if (group == "letters") "The letters are $length of the 17 plate letters." else "The $group is $length digits."
    }
}

package plates.countries.mexico

import plates.core.validators.*

private val fieldKeys = listOf("first", "second", "third")

/**
 * Judges a Mexican plate of one format, field by field. Reports, never bars a keystroke.
 *
 * [format] is a `MexicoFormat` id: dash-separated fields, `a` for a letter and `d` for a digit
 * (`aaa-dd-dd`, `ddd-aaa`, `d-aa-dd`). Mexico City (`ddd-aaa`) does not issue I, O or Q.
 */
class MexicoValidator(val format: String = "aaa-dd-dd") : GatedPlateValidator() {
    private val fields = format.split('-')

    override val gateGroup = fieldKeys[fields.size - 1]

    override fun judge(entry: PlateEntry): PlateValidation {
        for ((i, field) in fields.withIndex()) {
            val letters = field[0] == 'a'
            val value = entry.group(fieldKeys[i])
            val ok = if (letters) Regex("^[A-Z]{${field.length}}$").matches(value) else isDigitsOfLength(value, field.length)
            if (!ok) {
                return PlateValidation.invalid(
                    "Field ${i + 1} is ${field.length} ${if (letters) "letter" else "digit"}${if (field.length == 1) "" else "s"}.",
                )
            }
            if (format == "ddd-aaa" && letters && Regex("[IOQ]").containsMatchIn(value)) {
                return PlateValidation.invalid(REASON_CITY_LETTERS)
            }
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_CITY_LETTERS = "Letters I, O and Q are not used."
    }
}

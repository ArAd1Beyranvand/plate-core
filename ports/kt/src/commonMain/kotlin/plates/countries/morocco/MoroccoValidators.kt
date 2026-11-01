package plates.countries.morocco

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

/** One digit field a [MoroccoValidator] checks: its text-group key and how many digits the plate takes. */
class MoroccoField(val group: String, val min: Int, val max: Int)

/** Judges a Moroccan plate from its fields. Reports, never bars a keystroke. */
class MoroccoValidator(val fields: List<MoroccoField>, val requiresSeries: Boolean = false) : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        for (f in fields) {
            val v = entry.group(f.group)
            if (v.length < f.min || v.length > f.max || !isDigits(v)) {
                return PlateValidation.invalid(reasonFor(f))
            }
            if (v.replace("0", "").isEmpty()) return PlateValidation.invalid(REASON_ZERO)
        }
        if (requiresSeries && entry.group("series").isEmpty()) return PlateValidation.invalid(REASON_SERIES)
        return PlateValidation.valid
    }

    companion object {
        val standard = MoroccoValidator(listOf(MoroccoField("serial", 1, 5), MoroccoField("region", 1, 2)), true)
        val service = MoroccoValidator(listOf(MoroccoField("serial", 6, 6)))
        val navy = MoroccoValidator(listOf(MoroccoField("serial", 4, 4)))
        val trailer = MoroccoValidator(listOf(MoroccoField("serial", 4, 4), MoroccoField("region", 2, 2)))
        val dealer = MoroccoValidator(listOf(MoroccoField("serial", 5, 5)))
        val temporary = MoroccoValidator(listOf(MoroccoField("serial", 6, 6)))
        val mission = MoroccoValidator(listOf(MoroccoField("serial", 3, 3), MoroccoField("country", 2, 2)))

        fun reasonFor(f: MoroccoField) =
            if (f.min == f.max) "The ${f.group} is ${f.max} digits." else "The ${f.group} is ${f.min} to ${f.max} digits."

        const val REASON_SERIES = "The series letter is missing."
        const val REASON_ZERO = "The number cannot be all zeros."
    }
}

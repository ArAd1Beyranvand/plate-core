package plates.countries.liechtenstein

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

/** Advisory validator for the number ranges of one category. */
class LiechtensteinValidator(val ranges: List<Pair<Int, Int>>, val reason: String) : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val serial = entry.group("serial")
        val n = if (isDigits(serial)) serial.toIntOrNull() else null
        val ok = n != null && !serial.startsWith("0") && ranges.any { n >= it.first && n <= it.second }
        val month = entry.group("month")
        val m = month.toIntOrNull()
        val monthOk = month.isEmpty() || (m != null && m in 1..12)
        return if (ok && monthOk) PlateValidation.valid else PlateValidation.invalid(reason)
    }

    companion object {
        /** 1-20 are official, 2000-50000 general. */
        val standard = LiechtensteinValidator(
            listOf(1 to 20, 2000 to 50000),
            "A standard number is 1–20 (official) or 2000–50000.",
        )
        val trailer = LiechtensteinValidator(listOf(65100 to 70000), "A trailer number is 65100–70000.")
        val shortTerm = LiechtensteinValidator(listOf(50000 to 50299), "A short-term number is 50000–50299.")

        /** Agricultural, utility and exceptional plates share 21–2000; exceptional trailers run from 5000. */
        val special = LiechtensteinValidator(
            listOf(21 to 2000, 5000 to 9999),
            "A special-vehicle number is 21–2000, or from 5000 for a trailer.",
        )
        val lightMotorcycle = LiechtensteinValidator(listOf(7000 to 7999), "A light motorcycle number is 7000–7999.")
        val moped = LiechtensteinValidator(listOf(80000 to 89999), "A moped number is 80000–89999.")
        val dealer = LiechtensteinValidator(listOf(101 to 300), "A dealer number is 101–300.")
        val dealerMotorcycle = LiechtensteinValidator(listOf(501 to 999), "A motorcycle dealer number is from 501.")
        val temporary = LiechtensteinValidator(
            listOf(90000 to 92999, 95000 to 95099),
            "A temporary number is 90000–92999 or 95000–95099.",
        )
        val temporaryMotorcycle = LiechtensteinValidator(listOf(1801 to 1999), "A temporary motorcycle number is from 1801.")
        val customs = LiechtensteinValidator(listOf(600 to 799), "A customs number is from 600 (cars) or 700.")
    }
}

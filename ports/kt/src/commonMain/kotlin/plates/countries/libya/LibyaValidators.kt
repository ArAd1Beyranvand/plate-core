package plates.countries.libya

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

/** Advisory validator for any `LibyaPlates` value: municipality table, serial without a leading zero, foreign country table. */
class LibyaPlateValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val keys = entry.spec.textGroups.map { it.key }.toSet()
        if ("municipality" in keys) {
            val m = entry.group("municipality")
            if (!isDigits(m) || m.toInt() !in municipalities) return PlateValidation.invalid(REASON_MUNICIPALITY)
        }
        val s = entry.group("serial")
        if (!isDigits(s) || s.startsWith("0")) return PlateValidation.invalid(REASON_SERIAL)
        if ("country" in keys) {
            val c = entry.group("country")
            if (!isDigits(c) || c.toInt() !in countries) return PlateValidation.invalid(REASON_COUNTRY)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_MUNICIPALITY = "Not a municipality code in the published table."
        const val REASON_SERIAL = "The serial does not start with 0."
        const val REASON_COUNTRY = "Not a country code in the published table."

        /** 23, 29, 31, 34 and 39 are absent. */
        val municipalities: Set<Int> = (1..67).toSet() - setOf(23, 29, 31, 34, 39)

        val countries: Set<Int> = setOf(
            10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27,
            28, 30, 31, 32, 33, 34, 35, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
            48, 49, 50, 51, 52, 53, 54, 55, 56, 58, 59, 60, 61, 62, 63, 64, 65, 66,
            67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84,
            85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 99, 106, 108, 111,
            119, 120, 125, 130, 157, 180, 190,
        )
    }
}

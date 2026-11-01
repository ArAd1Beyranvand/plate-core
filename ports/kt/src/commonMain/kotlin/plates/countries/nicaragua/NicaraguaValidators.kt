package plates.countries.nicaragua

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

/**
 * Judges a 2005-series value. Reports, never throws, never bars a keystroke.
 *
 * Quiet until the number is in. Then the department code must be one seen on the series, and Managua (`M`) takes six digits where every other code takes three or four.
 */
class NicaraguaValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        // A split Managua number is not finished until its second half is in.
        if (entry.spec.indicesOfGroup("number_tail").isNotEmpty() && entry.group("number_tail").isEmpty()) {
            return PlateValidation.valid
        }
        val code = entry.group("department")
        val number = entry.group("number") + entry.group("number_tail")
        if (code !in departments) return PlateValidation.invalid(REASON_DEPARTMENT)
        if (!isDigits(number)) return PlateValidation.invalid(REASON_NUMBER)
        if (code == "M") {
            return if (number.length == 6) PlateValidation.valid else PlateValidation.invalid(REASON_MANAGUA)
        }
        return if (number.length == 3 || number.length == 4) PlateValidation.valid else PlateValidation.invalid(REASON_NUMBER)
    }

    companion object {
        /** Codes confirmed on 2005-series plates or in the sources' lists; the unconfirmed departments are not guessed at. */
        val departments = mapOf(
            "M" to "Managua",
            "MY" to "Masaya",
            "MT" to "Matagalpa",
            "CH" to "Chinandega",
            "CT" to "Chontales",
            "NS" to "Nueva Segovia",
            "ES" to "Estelí",
            "JI" to "Jinotega",
            "GR" to "Granada",
            "LE" to "León",
            "RN" to "Atlántico Norte",
            "RS" to "Atlántico Sur",
            "PN" to "Policía Nacional",
            "CD" to "Diplomatic corps",
            "CC" to "Consular corps",
            "MI" to "International mission",
        )

        const val REASON_DEPARTMENT = "The letters name no department."
        const val REASON_MANAGUA = "Managua numbers have six digits."
        const val REASON_NUMBER = "The number has three or four digits."
    }
}

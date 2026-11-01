package plates.countries.jordan

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

private fun range(from: Int, to: Int) = (from..to).map { "$it" }

// The codes each design carries (JordanUsage.codesOf in Dart).
private val codesBySpec = mapOf(
    "jo.private" to range(1, 49) + listOf("66", "77", "80", "88") + range(36, 45) + "81",
    "jo.motorcycle" to listOf("46", "47"),
    "jo.transport" to range(50, 60),
    "jo.rental" to listOf("70"),
    "jo.trailer" to listOf("71"),
    "jo.governmental" to listOf("PM", "PR", "SN", "JC", "GV", "AQ"),
    "jo.diplomatic" to listOf("CD"),
    "jo.police" to listOf("99"),
    "jo.ambulance" to listOf("95"),
    "jo.gendarmerie" to listOf("96"),
)

/** Judges a Jordanian plate: the serial is one to five digits and the code, where the article names them, is one the design carries. */
class JordanValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val code = entry.group("code")
        val serial = entry.group("serial")
        if (code.isEmpty()) return PlateValidation.invalid(REASON_CODE_MISSING)
        val known = codesBySpec[entry.spec.id] ?: emptyList()
        if (known.isNotEmpty() && code !in known) return PlateValidation.invalid(REASON_CODE_UNKNOWN)
        if (serial.isEmpty() || serial.length > MAX_SERIAL_LENGTH) return PlateValidation.invalid(REASON_SERIAL_LENGTH)
        if (!isDigits(serial)) return PlateValidation.invalid(REASON_SERIAL_NOT_NUMERIC)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_CODE_MISSING = "A plate starts with a code."
        const val REASON_CODE_UNKNOWN = "That code is not issued on this plate."
        const val REASON_SERIAL_NOT_NUMERIC = "The number is digits only."
        const val REASON_SERIAL_LENGTH = "The number is one to five digits."
        const val MAX_SERIAL_LENGTH = 5
    }
}

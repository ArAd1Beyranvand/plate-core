package plates.countries.slovenia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isLetters

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val regionCodes = listOf("CE", "GO", "KK", "KP", "KR", "LJ", "MB", "MS", "NM", "PO", "SG")

/** Judges a Slovenian plate by its three groups, `region`, `a`, `b`. Reports, never bars a keystroke. */
class SloveniaValidator : GatedPlateValidator() {
    override val gateGroup = "b"

    override fun judge(entry: PlateEntry): PlateValidation {
        val region = entry.group("region")
        val a = entry.group("a")
        val b = entry.group("b")
        val (ok, reason) = when {
            region == "P" -> (isDigitsOfLength(a, 2) && isDigitsOfLength(b, 3)) to REASON_POLICE
            region == "CD" -> (isDigitsOfLength(a, 2) && isDigitsOfLength(b, 2)) to REASON_DIPLOMATIC
            region !in regionCodes -> false to REASON_REGION
            else -> ((isDigitsOfLength(a, 3) && isLetters(b, 2)) ||
                (isLetters(a, 2) && isDigitsOfLength(b, 3))) to REASON_SERIAL
        }
        return if (ok) PlateValidation.valid else PlateValidation.invalid(reason)
    }

    companion object {
        const val REASON_REGION = "The unit code is two letters, e.g. LJ."
        const val REASON_POLICE = "Police is P, two digits, three digits."
        const val REASON_DIPLOMATIC = "Diplomatic is CD, two digits, two digits."
        const val REASON_SERIAL = "The serial is three digits and two letters, or two letters and three digits."
    }
}

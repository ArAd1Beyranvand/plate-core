package plates.countries.venezuela

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

// Keys of VenezuelaAlphabets.stateNames.
private val stateCodes = setOf(
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L",
    "M", "N", "O", "P", "R", "S", "T", "U", "V", "W", "X", "Y",
)

/** One vehicle category's serial: the six cells before the state letter. `L` is a letter, `D` a digit, any other character is printed as is. */
class VenezuelaCategory(val name: String, val pattern: String) {
    fun matches(serial: String): Boolean {
        if (serial.length != pattern.length) return false
        for (i in pattern.indices) {
            val c = serial.substring(i, i + 1)
            val ok = when (pattern[i]) {
                'L' -> isLetter(c)
                'D' -> isDigits(c)
                else -> c == pattern.substring(i, i + 1)
            }
            if (!ok) return false
        }
        return true
    }

    companion object {
        fun isLetter(c: String): Boolean = c.length == 1 && c[0] >= 'A' && c[0] <= 'Z'
    }
}

/** Reports, never throws, never bars a keystroke. Quiet until the state letter is in. */
class VenezuelaValidator : GatedPlateValidator() {
    override val gateGroup = "state"

    override fun judge(entry: PlateEntry): PlateValidation {
        val serial = entry.group("serial")
        if (serial.length != 6) return PlateValidation.invalid(REASON_SERIAL_LENGTH)
        if (entry.group("state") !in stateCodes) return PlateValidation.invalid(REASON_STATE)
        if (categoryOf(serial) == null) return PlateValidation.invalid(REASON_NO_CATEGORY)
        return PlateValidation.valid
    }

    companion object {
        /** The seven-character categories in the article's table, in its order. */
        val categories: List<VenezuelaCategory> = listOf(
            VenezuelaCategory("Private car", "LLDDDL"),
            VenezuelaCategory("Motorcycle", "LLDLDD"),
            VenezuelaCategory("Freight", "LDDLLD"),
            VenezuelaCategory("Crane", "LDDLDD"),
            VenezuelaCategory("School transport", "LDDDLD"),
            VenezuelaCategory("Private transport", "LDDDDL"),
            VenezuelaCategory("Tourist transport, rustic", "LDLLDD"),
            VenezuelaCategory("Tourist transport, minibus", "LDDLDL"),
            VenezuelaCategory("Tourist transport, bus", "LDLDLD"),
            VenezuelaCategory("Urban public transport", "0DLLDL"),
            VenezuelaCategory("Suburban public transport, car", "1DLDLD"),
            VenezuelaCategory("Suburban public transport, minibus", "2DLDDL"),
            VenezuelaCategory("Suburban public transport, bus", "3DLLDD"),
            VenezuelaCategory("Intercity public transport, car", "4DDLDL"),
            VenezuelaCategory("Intercity public transport, minibus", "5DDLLD"),
            VenezuelaCategory("Intercity public transport, bus", "6DDDLD"),
            VenezuelaCategory("Taxi", "7LDLDL"),
            VenezuelaCategory("Peripheral public transport, rustic", "8LDLDD"),
            VenezuelaCategory("Peripheral public transport, minibus", "9LDDDL"),
        )

        /** The category [serial] is written in, or null if it fits none. */
        fun categoryOf(serial: String): VenezuelaCategory? = categories.firstOrNull { it.matches(serial) }

        const val REASON_SERIAL_LENGTH = "The serial fills every cell."
        const val REASON_NO_CATEGORY = "The letters and digits are in no category's order."
        const val REASON_STATE = "The last letter names no state."
    }
}

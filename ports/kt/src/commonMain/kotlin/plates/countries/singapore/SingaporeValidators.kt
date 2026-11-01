package plates.countries.singapore

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigits

/** The checksum letter of a Singaporean registration (last two prefix letters, serial padded to four, weights 9 4 5 4 3 2, mod 19). */
object SingaporeChecksum {
    const val letters = "AZYXUTSRPMLKJHGEDCB"
    private val weights = listOf(9, 4, 5, 4, 3, 2)

    /** Null when [prefix] or [serial] is not a letter run of 1 to 3 and a digit run of 1 to 4. */
    fun of(prefix: String, serial: String): String? {
        if (prefix.isEmpty() || prefix.length > 3 || !prefix.all { it in 'A'..'Z' }) return null
        if (!isDigits(serial) || serial.length > 4) return null
        val tail = if (prefix.length > 2) prefix.substring(prefix.length - 2) else prefix
        val numbers = buildList {
            if (tail.length == 1) add(0)
            for (u in tail) add(u.code - 0x40)
            for (u in serial.padStart(4, '0')) add(u.code - 0x30)
        }
        var sum = 0
        for (i in 0 until 6) sum += numbers[i] * weights[i]
        return letters[sum % 19].toString()
    }
}

/** Judges a Singaporean registration: prefix, serial without leading zeros, checksum letter (empty passes). */
class SingaporeValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation =
        validateFields(entry.group("prefix"), entry.group("serial"), entry.group("check"))

    companion object {
        const val REASON_PREFIX = "The prefix is one to three letters."
        const val REASON_SERIAL = "The number is one to four digits, without leading zeros."
        const val REASON_CHECK = "The checksum letter does not match the number."

        fun validateFields(prefix: String, serial: String, check: String): PlateValidation {
            if (SingaporeChecksum.of(prefix, "0") == null) return PlateValidation.invalid(REASON_PREFIX)
            if (!isDigits(serial) || serial.length > 4 || serial.startsWith("0")) return PlateValidation.invalid(REASON_SERIAL)
            if (check.isNotEmpty() && check != SingaporeChecksum.of(prefix, serial)) return PlateValidation.invalid(REASON_CHECK)
            return PlateValidation.valid
        }
    }
}

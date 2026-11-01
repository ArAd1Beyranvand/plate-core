package plates.countries.laos

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** The consonants that may lead a provincial register, by the vehicle they mark. */
object LaosClassLetters {
    val passengerCar = setOf("ກ", "ຂ", "ຄ", "ນ", "ມ", "ຣ", "ລ", "ວ", "ຫ", "ອ", "ຮ")
    val motorbike = setOf("ຈ", "ຍ", "ດ", "ຕ", "ທ")
    val tricycle = setOf("ສ")
    val heavyTruck = setOf("ບ")
    val all = passengerCar + motorbike + tricycle + heavyTruck
}

private fun String.runeCount(): Int = length - count { it.isLowSurrogate() }

private fun String.firstRune(): String = if (isNotEmpty() && this[0].isHighSurrogate() && length > 1) substring(0, 2) else take(1)

/** Judges a provincial plate: two consonants, the first a class letter, and four digits. */
class LaosValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val letters = entry.group("letters")
        if (letters.runeCount() != 2) return PlateValidation.invalid(REASON_LETTERS)
        if (letters.firstRune() !in LaosClassLetters.all) return PlateValidation.invalid(REASON_CLASS)
        if (!isDigitsOfLength(entry.group("serial"), 4)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The register is two consonants."
        const val REASON_CLASS = "The first consonant is not a vehicle-class letter."
        const val REASON_SERIAL = "The number is four digits."
    }
}

/** Judges a temporary plate; the expiry is printed 2-4-2 and only its shape is checked. */
class LaosTemporaryValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("letters").runeCount() != 2) return PlateValidation.invalid(REASON_LETTERS)
        if (!isDigitsOfLength(entry.group("digit"), 1) || !isDigitsOfLength(entry.group("serial"), 3)) {
            return PlateValidation.invalid(REASON_SERIAL)
        }
        if (!isDigitsOfLength(entry.group("expiryLead"), 2) ||
            !isDigitsOfLength(entry.group("expiryYear"), 4) ||
            !isDigitsOfLength(entry.group("expiryTail"), 2)
        ) {
            return PlateValidation.invalid(REASON_EXPIRY)
        }
        return PlateValidation.valid
    }

    companion object {
        const val REASON_LETTERS = "The register is two consonants."
        const val REASON_SERIAL = "The number is one digit and three."
        const val REASON_EXPIRY = "The expiry date is 2-4-2 digits."
    }
}

/** Judges a prefixed plate: two-and-two digits on organisation plates, four on police and defence plates. */
class LaosPrefixedValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        val hasCode = entry.spec.indicesOfGroup("code").isNotEmpty()
        if (hasCode && !isDigitsOfLength(entry.group("code"), 2)) return PlateValidation.invalid(REASON_CODE)
        return if (isDigitsOfLength(entry.group("serial"), if (hasCode) 2 else 4)) {
            PlateValidation.valid
        } else {
            PlateValidation.invalid(REASON_SERIAL)
        }
    }

    companion object {
        const val REASON_CODE = "The code is two digits."
        const val REASON_SERIAL = "The number is two or four digits."
    }
}

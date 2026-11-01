package plates.countries.cambodia

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

/** Issued class digits: motorcycle 1, private car 2, large private car 3, agricultural 4, engineering 5, truck trailer 7, special 9. */
val cambodiaClassDigits = setOf("1", "2", "3", "4", "5", "7", "9")

/** Judges a captioned or long plate: class digit, one or two letters when the plate has them, four digits. */
class CambodiaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("class") !in cambodiaClassDigits) return PlateValidation.invalid(REASON_CLASS)
        if (entry.spec.indicesOfGroup("letters").isNotEmpty()) {
            // Code points, as Dart's runes.
            val letters = entry.group("letters").codePointCount()
            if (letters < 1 || letters > 2) return PlateValidation.invalid(REASON_LETTERS)
        }
        if (!isDigitsOfLength(entry.group("serial"), 4)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_CLASS = "The first number is not one of the article's vehicle classes."
        const val REASON_LETTERS = "The register is one or two letters."
        const val REASON_SERIAL = "The number is four digits."
    }
}

private fun String.codePointCount(): Int = count { !it.isLowSurrogate() }

/** Judges a stacked plate by the registers its spec has: CD + mission; ONG + organisation and class digit; or a two-digit code; each with a three-digit serial. */
class CambodiaStackedValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.spec.indicesOfGroup("prefix").isNotEmpty() && entry.group("prefix") !in setOf("CD", "ONG")) {
            return PlateValidation.invalid(REASON_PREFIX)
        }
        for (key in listOf("mission", "org", "code")) {
            if (entry.spec.indicesOfGroup(key).isNotEmpty() &&
                !isDigitsOfLength(entry.group(key), if (key == "org") 3 else 2)
            ) {
                return PlateValidation.invalid(REASON_CODE)
            }
        }
        if (!isDigitsOfLength(entry.group("serial"), 3)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is CD or ONG."
        const val REASON_CODE = "The code is two or three digits."
        const val REASON_SERIAL = "The number is three digits."
    }
}

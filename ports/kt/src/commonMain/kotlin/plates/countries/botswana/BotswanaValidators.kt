package plates.countries.botswana

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val register = Regex("^[A-PR-Z]{3}$")

/** Judges a private or public plate (`B 123 ABC`): the letter B, three digits and three letters, none of them Q. Reports, never bars a keystroke. */
class BotswanaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("prefix") != "B") return PlateValidation.invalid(REASON_PREFIX)
        if (!isDigitsOfLength(entry.group("serial"), 3)) return PlateValidation.invalid(REASON_SERIAL)
        if (!register.matches(entry.group("suffix"))) return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is B."
        const val REASON_SERIAL = "The number is three digits."
        const val REASON_SUFFIX = "The register is three letters, never Q."
    }
}

/** Judges a government plate (`BX 123456`): the prefix BX and six digits. */
class BotswanaGovernmentValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("prefix") != "BX") return PlateValidation.invalid(REASON_PREFIX)
        if (!isDigitsOfLength(entry.group("serial"), 6)) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is BX."
        const val REASON_SERIAL = "The number is six digits."
    }
}

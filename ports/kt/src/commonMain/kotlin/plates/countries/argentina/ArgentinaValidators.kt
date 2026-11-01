package plates.countries.argentina

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letters2 = Regex("^[A-Z]{2}$")
private val letters3 = Regex("^[A-Z]{3}$")

// ArgentinaAlphabets.missionClass / mission1985Class characters.
private val missionClass = listOf("D", "C", "M", "I", "A")
private val mission1985Class = listOf("CD", "CC", "ME", "OI", "PA")

/** Judges a Mercosur plate (`AB 123 CD`). Reports, never bars a keystroke. */
class ArgentinaStandardValidator : GatedPlateValidator() {
    override val gateGroup = "series"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters2.matches(entry.group("series"))) return PlateValidation.invalid(REASON_SERIES)
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_NUMBER)
        if (!letters2.matches(entry.group("suffix"))) return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_SERIES = "The series is two letters."
        const val REASON_NUMBER = "The number is three digits."
        const val REASON_SUFFIX = "The suffix is two letters."
    }
}

/** Judges a 1995-series plate (`ABC 123`). */
class ArgentinaLegacyValidator : GatedPlateValidator() {
    override val gateGroup = "series"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!letters3.matches(entry.group("series"))) return PlateValidation.invalid(REASON_SERIES)
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_SERIES = "The series is three letters."
        const val REASON_NUMBER = "The number is three digits."
    }
}

/** Judges a trailer plate (`101 ABC 123`): its own number, then the letters and digits of the primary mover. */
class ArgentinaTrailerValidator : GatedPlateValidator() {
    override val gateGroup = "trailer"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("trailer"), 3)) return PlateValidation.invalid(REASON_TRAILER)
        if (!letters3.matches(entry.group("series"))) return PlateValidation.invalid(REASON_SERIES)
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_TRAILER = "The trailer number is three digits."
        const val REASON_SERIES = "The mover's series is three letters."
        const val REASON_NUMBER = "The mover's number is three digits."
    }
}

/** Judges a 1995-series foreign-mission plate (`D 123 ABC`): one category letter (D, C, M, I or A), three digits and three letters. The article prints `D 123 xx A`; the photographs show three trailing letters, and the picture wins. */
class ArgentinaMissionValidator : GatedPlateValidator() {
    override val gateGroup = "prefix"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("prefix") !in missionClass) return PlateValidation.invalid("The category is D, C, M, I or A.")
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_NUMBER)
        if (!letters3.matches(entry.group("suffix"))) return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is three digits."
        const val REASON_SUFFIX = "The suffix is three letters."
    }
}

/** Judges a 1985 foreign-mission plate (`CD-1234`): prefix `CD`, `CC`, `ME`, `OI` or `PA`. */
class ArgentinaMission1985Validator : GatedPlateValidator() {
    override val gateGroup = "prefix"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("prefix") !in mission1985Class) {
            return PlateValidation.invalid("The category is CD, CC, ME, OI or PA.")
        }
        if (!isDigitsOfLength(entry.group("number"), 4)) return PlateValidation.invalid(REASON_NUMBER)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is four digits."
    }
}

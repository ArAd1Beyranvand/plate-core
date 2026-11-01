package plates.countries.albania

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isLetters

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val letter = Regex("^[A-Z]$")

/** Judges a private, repetitive or motorcycle plate (`AB 123 CD`; the motorcycle has no suffix). Reports, never bars a keystroke. */
class AlbaniaPrivateValidator : GatedPlateValidator() {
    override val gateGroup = "series"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isLetters(entry.group("series"), 2)) return PlateValidation.invalid(REASON_SERIES)
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_NUMBER)
        val suffix = entry.group("suffix")
        if (suffix.isNotEmpty() && !isLetters(suffix, 2)) return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_SERIES = "The series is two letters."
        const val REASON_NUMBER = "The number is three digits."
        const val REASON_SUFFIX = "The suffix is two letters."
    }
}

/** Judges an agricultural, technological or trailer plate: `AB MB 78`, `AB MT 78`, `AB RB 78`, `AB RT 78` (two digits) or `AB R 456` (three). */
class AlbaniaAgriculturalValidator : GatedPlateValidator() {
    override val gateGroup = "series"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isLetters(entry.group("series"), 2)) return PlateValidation.invalid(REASON_SERIES)
        val kind = entry.group("class")
        if (kind !in classes) return PlateValidation.invalid(REASON_CLASS)
        if (!isDigitsOfLength(entry.group("number"), if (kind == "R") 3 else 2)) {
            return PlateValidation.invalid(REASON_NUMBER)
        }
        return PlateValidation.valid
    }

    companion object {
        val classes = listOf("MB", "MT", "RB", "RT", "R")

        const val REASON_SERIES = "The series is two letters."
        const val REASON_CLASS = "The class is MB, MT, RB, RT or R."
        const val REASON_NUMBER = "The number is three digits after R, two after the others."
    }
}

/** Judges a diplomatic (`CD`) or service-diplomatic (`TR`) plate (`CD 12 03A`): the mission code, a two-digit number and a rank letter. */
class AlbaniaDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "prefix"

    override fun judge(entry: PlateEntry): PlateValidation {
        val prefix = entry.group("prefix")
        if (prefix != "CD" && prefix != "TR") return PlateValidation.invalid(REASON_PREFIX)
        if (!isDigitsOfLength(entry.group("code"), 2)) return PlateValidation.invalid(REASON_CODE)
        if (!isDigitsOfLength(entry.group("number"), 2)) return PlateValidation.invalid(REASON_NUMBER)
        if (!letter.matches(entry.group("suffix"))) return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is CD or TR."
        const val REASON_CODE = "The mission code is two digits."
        const val REASON_NUMBER = "The number is two digits."
        const val REASON_SUFFIX = "The rank is one letter."
    }
}

/** Judges a military plate (`MM 123PU`): the ministry prefix, three digits and a branch code. */
class AlbaniaMilitaryValidator : GatedPlateValidator() {
    override val gateGroup = "prefix"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("prefix") != "MM") return PlateValidation.invalid(REASON_PREFIX)
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_NUMBER)
        if (entry.group("suffix") !in branches) return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        val branches = listOf("FA", "FD", "FT", "KM", "PU", "SP")

        const val REASON_PREFIX = "The prefix is MM."
        const val REASON_NUMBER = "The number is three digits."
        const val REASON_SUFFIX = "The branch is FA, FD, FT, KM, PU or SP."
    }
}

/** Judges a police plate (`MB 123 AB`): the ministry prefix, three digits and two letters. */
class AlbaniaPoliceValidator : GatedPlateValidator() {
    override val gateGroup = "prefix"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("prefix") != "MB") return PlateValidation.invalid(REASON_PREFIX)
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_NUMBER)
        if (!isLetters(entry.group("suffix"), 2)) return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_PREFIX = "The prefix is MB."
        const val REASON_NUMBER = "The number is three digits."
        const val REASON_SUFFIX = "The suffix is two letters."
    }
}

/** Judges a taxi plate (`AB 123 T`). */
class AlbaniaTaxiValidator : GatedPlateValidator() {
    override val gateGroup = "series"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isLetters(entry.group("series"), 2)) return PlateValidation.invalid(REASON_SERIES)
        if (!isDigitsOfLength(entry.group("number"), 3)) return PlateValidation.invalid(REASON_NUMBER)
        if (entry.group("suffix") != "T") return PlateValidation.invalid(REASON_SUFFIX)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_SERIES = "The series is two letters."
        const val REASON_NUMBER = "The number is three digits."
        const val REASON_SUFFIX = "A taxi plate ends in T."
    }
}

/** Judges a temporary (`AB 0 PRK`) or test (`AB 0 PROV`) plate. */
class AlbaniaProvisionalValidator : GatedPlateValidator() {
    override val gateGroup = "series"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isLetters(entry.group("series"), 2)) return PlateValidation.invalid(REASON_SERIES)
        if (!isDigitsOfLength(entry.group("number"), 1)) return PlateValidation.invalid(REASON_NUMBER)
        val word = entry.group("word")
        if (word != "PRK" && word != "PROV") return PlateValidation.invalid(REASON_WORD)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_SERIES = "The series is two letters."
        const val REASON_NUMBER = "The number is one digit."
        const val REASON_WORD = "The word is PRK (temporary) or PROV (test)."
    }
}

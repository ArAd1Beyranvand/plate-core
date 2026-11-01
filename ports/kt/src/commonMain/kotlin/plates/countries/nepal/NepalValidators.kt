package plates.countries.nepal

import plates.core.validators.GatedPlateValidator
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.isDigitsOfLength
import plates.core.validators.isLetters

// H9: explicit ASCII classes, portable across JVM/JS/Wasm regex engines.
private val classRe = Regex("^[A-K][1-5]?$")
private val digits12 = Regex("^[0-9]{1,2}$")

/** Judges a plate of the 2020 series: `BAGMATI B AB 0123`. Reports, never bars a keystroke. */
class NepalValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("province").isEmpty()) return PlateValidation.invalid("Choose a province.")
        if (!classRe.matches(entry.group("class"))) {
            return PlateValidation.invalid("The class is a letter A to K, with a digit for a sub-class.")
        }
        if (!isLetters(entry.group("series"), 2)) return PlateValidation.invalid("The series is two letters.")
        if (!isDigitsOfLength(entry.group("number"), 4)) return PlateValidation.invalid("The number is 4 digits.")
        return PlateValidation.valid
    }
}

/** Judges a plate of the 1983-2019 series: zone, a one or two digit lot, a class letter and four digits (`X # X ####`). */
class NepalLegacyValidator : GatedPlateValidator() {
    override val gateGroup = "number"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (entry.group("zone").isEmpty()) return PlateValidation.invalid("Choose a zone.")
        if (!digits12.matches(entry.group("lot"))) return PlateValidation.invalid("The lot is 1 or 2 digits.")
        if (entry.group("class").isEmpty()) return PlateValidation.invalid("Choose a class letter.")
        if (!isDigitsOfLength(entry.group("number"), 4)) return PlateValidation.invalid("The number is 4 digits.")
        return PlateValidation.valid
    }
}

/** Judges a 1983-2019 diplomatic plate: a country or organisation number, the fixed `C.D.` and a serial, each 1 or 2 digits. */
class NepalDiplomaticValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!digits12.matches(entry.group("country"))) {
            return PlateValidation.invalid("The country number is 1 or 2 digits.")
        }
        if (!digits12.matches(entry.group("serial"))) return PlateValidation.invalid("The serial is 1 or 2 digits.")
        return PlateValidation.valid
    }
}

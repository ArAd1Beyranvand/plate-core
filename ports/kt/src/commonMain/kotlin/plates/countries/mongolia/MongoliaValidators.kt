package plates.countries.mongolia

import plates.core.validators.*

// MongoliaAlphabets.suffixes and .letters (Cyrillic; the Latin look-alikes of the article are stored as Cyrillic).
private val suffixes = listOf(
    "АР", "БН", "БР", "БӨ", "БУ", "ГА", "ГС", "ДА", "ДГ", "ДО", "ДУ", "ОР",
    "ХЭ", "ХО", "ХӨ", "НА", "ӨМ", "ӨВ", "СЭ", "СҮ", "СБ", "ТӨ", "УБ", "УН",
    "УА", "УЕ", "УК", "УВ", "ЗА",
)
private val letters = "А Б В Г Д Е Ё Ж З И Й К Л М Н О Ө П Р С Т У Ү Ф Х Ц Ч Ш Щ Ъ Ы Ь Э Ю Я".split(' ').toSet()

/**
 * Judges `1234 УБ А` by its groups `number`, `suffix` and `serial`: four digits (leading zeroes kept), a two-letter
 * aimag suffix from the article's table and one further Cyrillic letter. Gated on the serial, so nothing is
 * reported until the plate is complete. Reports, never bars a keystroke.
 */
class MongoliaValidator : GatedPlateValidator() {
    override val gateGroup = "serial"

    override fun judge(entry: PlateEntry): PlateValidation {
        if (!isDigitsOfLength(entry.group("number"), 4)) return PlateValidation.invalid(REASON_NUMBER)
        if (entry.group("suffix") !in suffixes) return PlateValidation.invalid(REASON_SUFFIX)
        if (entry.group("serial") !in letters) return PlateValidation.invalid(REASON_SERIAL)
        return PlateValidation.valid
    }

    companion object {
        const val REASON_NUMBER = "The number is four digits."
        const val REASON_SUFFIX = "The aimag suffix is not a known one."
        const val REASON_SERIAL = "The serial is one Cyrillic letter."
    }
}

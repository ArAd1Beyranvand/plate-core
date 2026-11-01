package plates.keypad

import plates.core.alphabet.PlateAlphabet

/** A row of the picker: the canonical character and the glyph it shows. */
data class PickerItem(val value: String, val glyph: String)

fun pickerItems(alphabet: PlateAlphabet) = alphabet.characters.map { PickerItem(it, alphabet.render(it)) }

/** U+267F is drawn as a vector icon; the font would fall back to a colour emoji. */
const val wheelchairGlyph = "♿"

const val wheelchairSvg =
    "<svg viewBox=\"0 0 24 24\" width=\"%S%\" height=\"%S%\" fill=\"currentColor\"><circle cx=\"12\" cy=\"4\" r=\"2\"/><path d=\"M19 13v-2c-1.5 0-3.3-.9-4.1-2l-1-1.6a2 2 0 0 0-1.7-.9c-.3 0-.5.1-.8.2L6 8.3V13h2V9.6l1.8-.7L8.2 17a2 2 0 0 0 2 2h5.4l3.2 3 1.4-1.4-4-3.6h-4.1l.5-2.7c1 1 2.7 1.7 4.5 1.7v-2Z\"/></svg>"

fun wheelchairIcon(size: Int) = wheelchairSvg.replace("%S%", size.toString())

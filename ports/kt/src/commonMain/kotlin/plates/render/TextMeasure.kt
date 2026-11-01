package plates.render

import plates.core.alphabet.splitRunes

/** [H12] Measures a line in plate units; the UI swaps in canvas measureText with the bundled font. */
typealias TextMeasurer = (text: String, style: TextStyle) -> Double

/** A headless estimate: 0.6 em per code point plus letter spacing. Layout only, never compared. */
var measureText: TextMeasurer = { text, s -> splitRunes(text).size * (s.fontSize * 0.6 + s.letterSpacing) }

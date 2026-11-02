package plates.core.input

import plates.core.alphabet.AlphabetInput

/** [input] shows editable fields; [display] shows bare glyphs, as printed. */
enum class PlateMode { input, display }

/** What a slot does about input, resolved once per build. */
enum class SlotBehavior { glyph, imeField, hardwareField, externalField, keypadFirstField, sheet }

/** A chosen alphabet reaches [SlotBehavior.sheet] only under [PlateInputSource.system]. */
fun resolveSlotBehavior(mode: PlateMode, input: AlphabetInput, source: PlateInputSource): SlotBehavior =
    if (mode == PlateMode.display) SlotBehavior.glyph
    else when (source) {
        PlateInputSource.system -> if (input == AlphabetInput.typed) SlotBehavior.imeField else SlotBehavior.sheet
        PlateInputSource.hardwareKeyboard -> SlotBehavior.hardwareField
        PlateInputSource.packageKeypad, PlateInputSource.host -> SlotBehavior.externalField
        PlateInputSource.keypadFirst -> SlotBehavior.keypadFirstField
    }

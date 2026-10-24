import 'plate_alphabet.dart';
import 'plate_input_source.dart';
import 'plate_number.dart';

/// What a slot does about input, resolved once per build; rendering and
/// gestures switch on it rather than re-deriving it.
enum SlotBehavior {
  /// Read-only glyph ([PlateMode.display]).
  glyph,

  /// TextField with the platform IME.
  imeField,

  /// TextField with the IME suppressed; physical keys are consumed.
  hardwareField,

  /// Characters arrive from a keypad or the host. IME suppressed; a tap only
  /// claims focus.
  externalField,

  /// [PlateInputSource.keypadFirst]: a text field for every slot, chosen ones
  /// included; a tap asks for the platform keyboard.
  keypadFirstField,

  /// Tapping opens the character picker.
  sheet,
}

/// A [AlphabetInput.chosen] alphabet reaches [SlotBehavior.sheet] only under
/// [PlateInputSource.system]; every other source drives its own field type.
SlotBehavior resolveSlotBehavior({
  required PlateMode mode,
  required AlphabetInput input,
  required PlateInputSource source,
}) {
  if (mode == PlateMode.display) return SlotBehavior.glyph;
  switch (source) {
    case PlateInputSource.system:
      return input == AlphabetInput.typed ? SlotBehavior.imeField : SlotBehavior.sheet;
    case PlateInputSource.hardwareKeyboard:
      return SlotBehavior.hardwareField;
    case PlateInputSource.packageKeypad:
    case PlateInputSource.host:
      return SlotBehavior.externalField;
    case PlateInputSource.keypadFirst:
      return SlotBehavior.keypadFirstField;
  }
}

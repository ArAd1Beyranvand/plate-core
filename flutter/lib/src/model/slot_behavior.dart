import 'plate_alphabet.dart';
import 'plate_input_source.dart';

/// [input] shows editable fields; [display] shows bare glyphs, as printed.
enum PlateMode { input, display }

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
}) => mode == .display
    ? .glyph
    : switch (source) {
        .system => input == .typed ? .imeField : .sheet,
        .hardwareKeyboard => .hardwareField,
        .packageKeypad || .host => .externalField,
        .keypadFirst => .keypadFirstField,
      };

import 'package:flutter/widgets.dart';

/// The characters a slot accepts and how they are rendered. Digits and letters
/// differ only in [characters] and [input].
@immutable
class PlateAlphabet {
  const PlateAlphabet({
    required this.id,
    required this.characters,
    required this.input,
    required this.isNumeric,
    this.glyphs = const <String, String>{},
    this.direction = TextDirection.ltr,
    this.placeholder = '?',
  });

  /// Equality key: two alphabets are equal iff their ids match, so ids must be
  /// unique across a spec.
  final String id;

  /// Every legal character in canonical (storage) form, in picker order.
  final List<String> characters;

  final AlphabetInput input;

  /// Storage form to display form; empty when they coincide. National numerals
  /// live here.
  final Map<String, String> glyphs;

  /// A property of the script, not inferable from [characters].
  final TextDirection direction;

  /// Shown in an empty chosen slot.
  final String placeholder;

  /// True when every legal character is an ASCII digit; picks the numeric
  /// keyboard. Declared rather than derived because a `const` constructor
  /// cannot compute it and this sits on the slot build path.
  final bool isNumeric;

  /// Whether [value] is legal in storage (`'5'`) or display (`'۵'`) form.
  bool accepts(String value) => characters.contains(canonical(value));

  /// [value] folded to storage form (`'۵'` -> `'5'`). A lowercase letter whose
  /// uppercase is legal folds to it; anything else is returned unchanged.
  String canonical(String value) {
    if (characters.contains(value)) return value;
    // A glyph shared by two storage characters folds to the one listed first.
    for (final entry in glyphs.entries) {
      if (entry.value == value) return entry.key;
    }
    final upper = value.toUpperCase();
    return upper != value && characters.contains(upper) ? upper : value;
  }

  /// The display form of [value].
  String render(String value) => glyphs[value] ?? value;

  /// [render] over every character of a multi-character [value].
  String renderAll(String value) => _each(value, render);

  /// [canonical] over every character of a multi-character [value].
  String canonicalAll(String value) => _each(value, canonical);

  static String _each(String value, String Function(String) f) =>
      value.runes.map((r) => f(String.fromCharCode(r))).join();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PlateAlphabet && other.id == id);

  @override
  int get hashCode => id.hashCode;

  static const PlateAlphabet latinDigits = PlateAlphabet(
    id: 'latin.digits',
    characters: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
    input: AlphabetInput.typed,
    isNumeric: true,
  );

  static const PlateAlphabet latinUppercase = PlateAlphabet(
    id: 'latin.upper',
    characters: [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}

enum AlphabetInput {
  /// Typed into a TextField.
  typed,

  /// Picked from a chooser or fed in by the host, for characters absent from a
  /// normal keyboard.
  chosen,
}

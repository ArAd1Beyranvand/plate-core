import 'package:flutter/widgets.dart';

/// The characters a slot accepts and how they are rendered. Digits and letters
/// differ only in [characters] and [input].
@immutable
class PlateAlphabet {
  const PlateAlphabet({
    required this.id,
    required List<String> characters,
    required this.input,
    required this.isNumeric,
    this.glyphs = const <String, String>{},
    this.direction = TextDirection.ltr,
    this.placeholder = '?',
  }) : _listed = characters,
       _include = '',
       _exclude = '';

  /// An alphabet written as a pattern instead of a list. [include] and
  /// [exclude] are space-separated tokens: `X-Y` is every single character from
  /// `X` to `Y`, anything else is one literal character (or a multi-character
  /// entry such as `MP`). Excluded tokens are removed from the included ones.
  /// `include: 'A-Z', exclude: 'I O Q'` is the Latin capitals less three.
  const PlateAlphabet.pattern({
    required this.id,
    required String include,
    String exclude = '',
    required this.input,
    required this.isNumeric,
    this.glyphs = const <String, String>{},
    this.direction = TextDirection.ltr,
    this.placeholder = '?',
  }) : _listed = null,
       _include = include,
       _exclude = exclude;

  final List<String>? _listed;
  final String _include;
  final String _exclude;

  static final Map<String, List<String>> _expanded = <String, List<String>>{};

  static List<String> _expand(String include, String exclude) {
    final drop = _tokens(exclude).toSet();
    return List<String>.unmodifiable(
      _tokens(include).where((c) => !drop.contains(c)),
    );
  }

  static Iterable<String> _tokens(String pattern) sync* {
    for (final token in pattern.split(' ')) {
      if (token.isEmpty) continue;
      final runes = token.runes.toList();
      if (runes.length == 3 && runes[1] == 0x2D) {
        for (var r = runes[0]; r <= runes[2]; r++) {
          yield String.fromCharCode(r);
        }
      } else {
        yield token;
      }
    }
  }

  /// Equality key: two alphabets are equal iff their ids match, so ids must be
  /// unique across a spec.
  final String id;

  /// Every legal character in canonical (storage) form, in picker order.
  List<String> get characters =>
      _listed ??
      _expanded.putIfAbsent(
        '$_include|$_exclude',
        () => _expand(_include, _exclude),
      );

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

  /// [render] over every character of a multi-character [value], or over
  /// [value] whole when it is one multi-character token (`'HRT'` -> `'هرات'`).
  String renderAll(String value) => glyphs[value] ?? _each(value, render);

  /// [canonical] over every character of a multi-character [value], or over
  /// [value] whole when it is one token in either form.
  String canonicalAll(String value) {
    final whole = canonical(value);
    return characters.contains(whole) ? whole : _each(value, canonical);
  }

  static String _each(String value, String Function(String) f) =>
      value.runes.map((r) => f(String.fromCharCode(r))).join();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PlateAlphabet && other.id == id);

  @override
  int get hashCode => id.hashCode;

  static const PlateAlphabet latinDigits = PlateAlphabet.pattern(
    id: 'latin.digits',
    include: '0-9',
    input: AlphabetInput.typed,
    isNumeric: true,
  );

  static const PlateAlphabet latinUppercase = PlateAlphabet.pattern(
    id: 'latin.upper',
    include: 'A-Z',
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

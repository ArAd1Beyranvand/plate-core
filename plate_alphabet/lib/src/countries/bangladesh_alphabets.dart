import 'package:plate_core/plate_core.dart';

/// The alphabets behind Bangladeshi slots.
///
/// The plates print Bengali letters and Bengali numerals. [digits] stores
/// `0-9` and prints `০-৯`. [city] and [vehicleClass] are picked a symbol at a
/// time: each stores the BRTA's Latin code and prints the Bengali it stands
/// for, so a value is one space-free token.
abstract final class BangladeshAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.pattern(
    id: 'bd.digits',
    include: '0-9',
    input: AlphabetInput.typed,
    isNumeric: true,
    glyphs: <String, String>{
      '0': '০', '1': '১', '2': '২', '3': '৩', '4': '৪', //
      '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯',
    },
  );

  // TODO(py): [H7] one entry, 'DHAKA' -> 11 code points incl. Bengali vowel signs (grapheme clusters); never split the glyph.
  // TODO(ts): [H7] glyph is a multi-cluster string: measure/render whole, not by Array.from. [D6-font] bundle Bengali.
  // TODO(kt): [H7] glyph has combining vowel signs; don't iterate chars. [D6-font] bundle a Bengali font.
  /// The registration city. The article shows only Dhaka Metro.
  static const PlateAlphabet city = PlateAlphabet(
    id: 'bd.city',
    characters: <String>['DHAKA'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    glyphs: <String, String>{'DHAKA': 'ঢাকা মেট্রো'},
    placeholder: '—',
  );

  /// The vehicle-class letters of the article's table, by BRTA code.
  static const PlateAlphabet vehicleClass = PlateAlphabet.pattern(
    id: 'bd.class',
    include:
        'A HA LA KA KHA GA BHA GHA CHA PA CAA JA JHA BA SA TWA TAW DWA FA THA MA NA AU DA U TA DHA SHA E ZA RA',
    input: AlphabetInput.chosen,
    isNumeric: false,
    glyphs: <String, String>{
      'A': 'এ', 'HA': 'হ', 'LA': 'ল', 'KA': 'ক', 'KHA': 'খ', 'GA': 'গ', //
      'BHA': 'ভ', 'GHA': 'ঘ', 'CHA': 'চ', 'PA': 'প', 'CAA': 'ছ', 'JA': 'জ', //
      'JHA': 'ঝ', 'BA': 'ব', 'SA': 'স', 'TWA': 'ত', 'TAW': 'থ', 'DWA': 'দ', //
      'FA': 'ফ', 'THA': 'ঠ', 'MA': 'ম', 'NA': 'ন', 'AU': 'অ', 'DA': 'ড', //
      'U': 'উ', 'TA': 'ট', 'DHA': 'ঢ', 'SHA': 'শ', 'E': 'ই', 'ZA': 'য', //
      'RA': 'র',
    },
    placeholder: '—',
  );
}

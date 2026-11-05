import 'package:plate_core/plate_core.dart';

/// The alphabets behind Czech slots.
///
/// Letters are the 26 Latin capitals without diacritics. The regional letter
/// (`A B C E H J K L M P S T U Z`) is a validator rule, not an alphabet: the
/// field it sits in also takes digits.
abstract final class CzechRepublicAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'cz.letters',
    include: 'A-Z',
  );

  /// Fields that mix both, such as `1A2`, `B174` and personalised plates.
  static const PlateAlphabet alphanumeric = PlateAlphabet.pattern(
    id: 'cz.alphanumeric',
    include: 'A-Z 0-9',
  );
}

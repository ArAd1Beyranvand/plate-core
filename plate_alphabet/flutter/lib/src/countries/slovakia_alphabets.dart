import 'package:plate_core/plate_core.dart';

/// The alphabets behind Slovak slots.
///
/// Serial letters are the 24 the article lists: the Latin capitals without Q
/// and W, and none of the Slovak diacritics.
abstract final class SlovakiaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'sk.letters',
    include: 'A-Z',
    exclude: 'Q W',
  );

  /// A personalised plate takes any capital letter or digit.
  static const PlateAlphabet personalised = PlateAlphabet.pattern(
    id: 'sk.personalised',
    include: 'A-Z 0-9',
  );
}

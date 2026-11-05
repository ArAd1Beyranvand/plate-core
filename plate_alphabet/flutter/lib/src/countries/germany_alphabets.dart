import 'package:plate_core/plate_core.dart';

/// The alphabets a German plate's slots are drawn over.
///
/// Area code admits Ä, Ö, Ü but identifier does not (umlaut in identifier
/// marks a fake plate by film convention).
class GermanAlphabets {
  const GermanAlphabets._();

  /// A-Z plus Ä, Ö, Ü: legal area code letters. Umlauts group at end (picker UX).
  static const PlateAlphabet districtLetters = PlateAlphabet.pattern(
    id: 'de.district',
    include: 'A-Z Ä Ö Ü',
  );
}

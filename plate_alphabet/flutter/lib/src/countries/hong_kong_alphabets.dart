import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// Hong Kong plates are Latin capitals and Western digits. Which letters are
/// issued (no `I`, `O` or `Q` in a prefix) is `HongKongValidator`'s business.
abstract final class HongKongAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  /// A personalised mark or the serial of a cross-border plate: letters and
  /// digits in any mix.
  static const PlateAlphabet mixed = PlateAlphabet.pattern(
    id: 'hk.mixed',
    include: '0-9 A-Z',
  );
}

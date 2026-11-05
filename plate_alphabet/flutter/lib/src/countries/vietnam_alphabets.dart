import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Vietnamese slots.
///
/// [series] is the civil serial letter: the article says a civil plate omits
/// I, J, O, Q and W and includes Đ. [letters] is all of A–Z, for the military
/// unit code, the `T` of a temporary plate and the NG/QT/NN status code, none
/// of which follow the civil rule. [seriesOrDigit] is the second cell of a
/// motorcycle's `NN-LN` / `NN-LL` series. The rules live in the validators;
/// these only say what a key may type.
abstract final class VietnamAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet series = PlateAlphabet.pattern(
    id: 'vn.series',
    include: 'A-D Đ E-Z',
    exclude: 'I J O Q W',
  );

  static const PlateAlphabet seriesOrDigit = PlateAlphabet.pattern(
    id: 'vn.seriesOrDigit',
    include: 'A-D Đ E-Z 0-9',
    exclude: 'I J O Q W',
  );

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'vn.letters',
    include: 'A-Z',
  );
}

import 'package:plate_core/plate_core.dart';

/// The alphabets behind Cameroonian slots. The article restricts neither the
/// letters nor the digits, so letters are the 26 of Latin.
abstract final class CameroonAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'cm.letters',
    include: 'A-Z',
  );
}

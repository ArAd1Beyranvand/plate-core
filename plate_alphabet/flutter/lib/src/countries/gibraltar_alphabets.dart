import 'package:plate_core/plate_core.dart';

/// The alphabets behind Gibraltar slots.
///
/// Plates are Latin capitals and ASCII digits, as in the United Kingdom. Which
/// series letters are issued is the validator's business.
abstract final class GibraltarAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  /// The `G` of a private plate or the `GT` of a trailer plate.
  static const PlateAlphabet prefix = PlateAlphabet(
    id: 'gi.prefix',
    characters: <String>['G', 'T'],
  );
}

import 'package:plate_core/plate_core.dart';

/// Ascension Island plates are an `A` and digits, as on Saint Helena.
abstract final class AscensionIslandAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  /// The fixed `A` that opens every mark.
  static const PlateAlphabet prefix = PlateAlphabet(
    id: 'ac.prefix',
    characters: <String>['A'],
  );
}

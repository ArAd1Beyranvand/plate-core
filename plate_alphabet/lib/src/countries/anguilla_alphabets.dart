import 'package:plate_core/plate_core.dart';

/// Anguillan plates are Latin capitals and ASCII digits: a vehicle-type
/// letter, then up to four digits (`A 123`).
abstract final class AnguillaAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}

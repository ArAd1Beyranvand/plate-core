import 'package:plate_core/plate_core.dart';

/// The alphabets behind South Ossetian slots.
///
/// The plates follow Russia's GOST 3207-77 design and use the same twelve
/// Cyrillic capitals with a Latin twin (А В Е К М Н О Р С Т У Х), stored as
/// the Latin twins, which print identically.
abstract final class SouthOssetiaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'so.letters',
    include: 'A B E K M H O P C T Y X',
  );
}

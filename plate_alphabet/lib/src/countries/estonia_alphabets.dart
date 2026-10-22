import 'package:plate_core/plate_core.dart';

/// The alphabets behind Estonian slots.
///
/// Plates are ASCII digits and the Latin capitals A–Z; the national letters
/// Õ, Ä, Ö, Ü and Š, Ž are not printed on any plate in the references.
abstract final class EstoniaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}

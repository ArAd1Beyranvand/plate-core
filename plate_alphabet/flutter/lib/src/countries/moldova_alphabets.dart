import 'package:plate_core/plate_core.dart';

/// Moldovan plates print Latin capitals and Western digits only.
abstract final class MoldovaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'md.letters',
    include: 'A-Z',
  );
}

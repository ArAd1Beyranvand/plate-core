import 'package:plate_core/plate_core.dart';

/// Transnistrian plates print Latin capitals and Western digits only, in the
/// DIN 1451 face.
abstract final class TransnistriaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'pmr.letters',
    include: 'A-Z',
  );
}

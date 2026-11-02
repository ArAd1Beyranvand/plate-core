import 'package:plate_core/plate_core.dart';

/// The alphabets behind Tristan da Cunha slots.
///
/// The plates print "T.D.C." as a fixed prefix and then up to three Latin
/// digits, so only [digits] is typed.
abstract final class TristanDaCunhaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}

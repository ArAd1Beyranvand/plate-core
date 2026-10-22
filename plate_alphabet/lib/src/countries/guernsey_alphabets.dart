import 'package:plate_core/plate_core.dart';

/// The alphabets behind Guernsey slots.
///
/// Guernsey marks are digits only (up to five); Alderney's printed `AY` is a
/// fixed label, so its typed field is a digit run too.
abstract final class GuernseyAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}

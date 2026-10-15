import 'package:plate_core/plate_core.dart';

/// The alphabets behind Liechtenstein slots.
///
/// The typed part of every current plate is ASCII digits: `FL` and the dealer
/// `U` and customs `Z` are printed, not chosen. The expiry month on a
/// temporary plate's red bar is digits too.
abstract final class LiechtensteinAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}

import 'package:plate_core/plate_core.dart';

/// The alphabets behind Icelandic slots.
///
/// Registration letters are the 26 Latin capitals; the Icelandic letters
/// appear only on vanity plates ("2-6 characters of the Icelandic alphabet as
/// well as numbers"). The diplomatic and dealer plates carry a fixed prefix,
/// `CD` and `RN`.
abstract final class IcelandAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'is.letters',
    include: 'A-Z',
  );

  /// The three-character field: `123` or `C12`.
  static const PlateAlphabet serial = PlateAlphabet.pattern(
    id: 'is.serial',
    include: 'A-Z 0-9',
  );

  static const PlateAlphabet diplomaticPrefix = PlateAlphabet(
    id: 'is.diplomatic.prefix',
    characters: <String>['C', 'D'],
  );

  static const PlateAlphabet dealerPrefix = PlateAlphabet(
    id: 'is.dealer.prefix',
    characters: <String>['R', 'N'],
  );

  static const PlateAlphabet vanity = PlateAlphabet.pattern(
    id: 'is.vanity',
    include: 'A-Z Á Ð É Í Ó Ú Ý Þ Æ Ö 0-9',
  );
}

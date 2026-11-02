import 'package:plate_core/plate_core.dart';

import 'lebanon_letters.dart';

// TODO(py): [D4-code] hand-port; reason strings are the contract, keep them byte-identical.
// TODO(ts): [D4-code] hand-port; reason strings are the contract, keep them byte-identical.
// TODO(kt): [D4-code] hand-port; reason strings are the contract, keep them byte-identical.
/// Advisory validator; never bars a keystroke. Waits for a non-empty serial.
///
/// Checks the letter against the closed set, a 1-6 digit serial, and 1-128 for
/// MP. Number allocation and the obsolete `K` are deliberately not checked:
/// there is no published per-town range, and K plates are on the road.
class LebanonValidator extends GatedPlateValidator {
  const LebanonValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonLetterMissing = 'A plate starts with a letter.';
  static const String reasonLetterUnknown =
      'That is not a Lebanese plate letter.';
  static const String reasonSerialNotNumeric = 'The number is digits only.';
  static const String reasonSerialLength = 'The number is one to six digits.';
  static const String reasonParliamentRange =
      'A parliament plate is numbered 1 to 128.';

  static const int minSerialLength = 1;
  static const int maxSerialLength = 6;
  static const int maxParliamentNumber = 128;

  @override
  PlateValidation judge(PlateEntry entry) => validateFields(
    letter: entry.group('letter'),
    serial: entry.group('serial'),
  );

  static PlateValidation validateFields({
    required String letter,
    required String serial,
  }) {
    if (letter.isEmpty) {
      return const PlateValidation.invalid(reasonLetterMissing);
    }
    final LebanonLetter? code = LebanonLetter.fromCharacter(letter);
    if (code == null) {
      return const PlateValidation.invalid(reasonLetterUnknown);
    }

    if (serial.length < minSerialLength || serial.length > maxSerialLength) {
      return const PlateValidation.invalid(reasonSerialLength);
    }
    if (!isDigits(serial)) {
      return const PlateValidation.invalid(reasonSerialNotNumeric);
    }

    if (code == LebanonLetter.mp) {
      final int number = int.parse(serial);
      if (number < 1 || number > maxParliamentNumber) {
        return const PlateValidation.invalid(reasonParliamentRange);
      }
    }

    return const PlateValidation.valid();
  }
}

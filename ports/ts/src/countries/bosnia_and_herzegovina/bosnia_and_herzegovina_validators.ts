import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a plate by its groups. Reports, never bars a keystroke.
 *
 * A private or agricultural serial is `X00-X-000`: a digit or one of
 * `A E J K M O T`, two digits, one of those letters, three digits. Taxi,
 * temporary and EUPM plates carry fixed text and are judged on six or four
 * digits; a diplomatic plate is a two-digit code from 10 to 49 (not 31),
 * a letter and three digits. */
export class BosniaAndHerzegovinaValidator extends GatedPlateValidator {
  readonly gateGroup = 'digits';

  static readonly reasonSerial = 'A plate is X00-X-000.';
  static readonly reasonSix = 'The plate carries six digits.';
  static readonly reasonFour = 'An EUPM plate carries four digits.';
  static readonly reasonDiplomatic =
    'A diplomatic plate is a code from 10 to 49, a letter and three digits.';

  judge(entry: PlateEntry): PlateValidation {
    const digits = entry.group('digits');
    const prefix = entry.group('prefix');
    const letter = entry.group('letter');
    const code = entry.group('code');

    if (code.length > 0) {
      const n = parseInt(code, 10);
      if (
        !isNaN(n) &&
        n >= 10 &&
        n <= 49 &&
        n !== 31 &&
        letter.length === 1 &&
        isDigitsOfLength(digits, 3)
      ) {
        return valid;
      }
      return invalid(BosniaAndHerzegovinaValidator.reasonDiplomatic);
    }

    if (prefix.length > 0) {
      if (
        prefix.length === 3 &&
        letter.length === 1 &&
        isDigitsOfLength(digits, 3)
      ) {
        return valid;
      }
      return invalid(BosniaAndHerzegovinaValidator.reasonSerial);
    }

    if (isDigitsOfLength(digits, 6)) {
      return valid;
    }

    if (isDigitsOfLength(digits, 4)) {
      return valid;
    }

    return invalid(BosniaAndHerzegovinaValidator.reasonSix);
  }
}

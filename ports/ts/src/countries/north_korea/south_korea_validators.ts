import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, isDigits, valid } from '../../core/validators/plate_validator';

/** Judges the class digits (two or three on a passenger plate since 2019, one
to two on others), the Hangul syllable and the serial. */
export class SouthKoreaValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonIncomplete = 'Every field must be filled.';
  static readonly reasonClass = 'The class number is out of range.';
  static readonly reasonDiplomatic = 'A diplomatic plate is two groups of three digits.';
  static readonly reasonUsForces = 'A US Forces plate is one digit and four digits.';

  judge(entry: PlateEntry): PlateValidation {
    const id = entry.spec.id;
    const cls = entry.group('class');
    const serial = entry.group('serial');
    const letter = entry.group('letter');

    if (id === 'kr.diplomatic') {
      return isDigitsOfLength(cls, 3) && isDigitsOfLength(serial, 3)
        ? valid
        : invalid(SouthKoreaValidator.reasonDiplomatic);
    }
    if (id === 'kr.us_forces') {
      return isDigitsOfLength(cls, 1) && isDigitsOfLength(serial, 4)
        ? valid
        : invalid(SouthKoreaValidator.reasonUsForces);
    }

    const commercial = id === 'kr.commercial';
    if (letter.length === 0 ||
        !isDigitsOfLength(serial, 4) ||
        (commercial && entry.group('region').length === 0)) {
      return invalid(SouthKoreaValidator.reasonIncomplete);
    }
    const digits = cls.length;
    if (!isDigits(cls) ||
        digits < 2 ||
        digits > 3 ||
        (digits === 3 && commercial)) {
      return invalid(SouthKoreaValidator.reasonClass);
    }
    return valid;
  }
}

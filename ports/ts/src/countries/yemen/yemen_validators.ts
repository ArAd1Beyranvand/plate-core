import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

const minGovernorate = 1;
const maxGovernorate = 22;

/** Judges a System A (2026 unified) plate, gated on the side code so it stays
 * quiet until the number is entered. The side code is checked for shape only. */
export class YemenUnifiedValidator extends GatedPlateValidator {
  readonly gateGroup = 'sideCode';

  static readonly reasonNumberNotNumeric = 'The vehicle number is digits only.';
  static readonly reasonNumberLength = 'The vehicle number is four to six digits.';
  static readonly reasonSideCodeNotNumeric = 'The side code is digits only.';
  static readonly reasonSideCodeLength = 'The side code is two digits.';
  static readonly minNumberLength = 4;
  static readonly maxNumberLength = 6;

  judge(entry: PlateEntry): PlateValidation {
    return YemenUnifiedValidator.validateFields({ number: entry.group('number'), sideCode: entry.group('sideCode') });
  }

  static validateFields({ number, sideCode }: { number: string; sideCode: string }): PlateValidation {
    if (number !== '' && !isDigits(number)) {
      return invalid(YemenUnifiedValidator.reasonNumberNotNumeric);
    }
    if (number.length < YemenUnifiedValidator.minNumberLength || number.length > YemenUnifiedValidator.maxNumberLength) {
      return invalid(YemenUnifiedValidator.reasonNumberLength);
    }
    if (!isDigits(sideCode)) {
      return invalid(YemenUnifiedValidator.reasonSideCodeNotNumeric);
    }
    if (sideCode.length !== 2) {
      return invalid(YemenUnifiedValidator.reasonSideCodeLength);
    }
    return valid;
  }
}

/** Judges a System B (1993 northern) plate, gated on the serial. Checks more
 * than YemenUnifiedValidator because this grammar is documented: governorate
 * 1..22, serial never zero-padded. */
export class YemenNorthernValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonGovernorateNotNumeric = 'The governorate code is digits only.';
  static readonly reasonGovernorateLength = 'The governorate code is one or two digits.';
  static readonly reasonGovernorateRange = 'The governorate code is 1 to 22.';
  static readonly reasonSerialNotNumeric = 'The serial is digits only.';
  static readonly reasonSerialLength = 'The serial is four to six digits.';
  static readonly reasonSerialLeadingZero = 'The serial is not padded with leading zeros.';
  static readonly minSerialLength = 4;
  static readonly maxSerialLength = 6;

  judge(entry: PlateEntry): PlateValidation {
    return YemenNorthernValidator.validateFields({ governorate: entry.group('governorate'), serial: entry.group('serial') });
  }

  /** `'05'` and `'5'` are the same governorate (two-cell padding). */
  static validateFields({ governorate, serial }: { governorate: string; serial: string }): PlateValidation {
    const C = YemenNorthernValidator;
    if (governorate === '' || governorate.length > 2) {
      return invalid(C.reasonGovernorateLength);
    }
    if (!isDigits(governorate)) {
      return invalid(C.reasonGovernorateNotNumeric);
    }
    const code = parseInt(governorate, 10);
    if (code < minGovernorate || code > maxGovernorate) {
      return invalid(C.reasonGovernorateRange);
    }
    if (serial.length < C.minSerialLength || serial.length > C.maxSerialLength) {
      return invalid(C.reasonSerialLength);
    }
    if (!isDigits(serial)) {
      return invalid(C.reasonSerialNotNumeric);
    }
    if (serial.startsWith('0')) {
      return invalid(C.reasonSerialLeadingZero);
    }
    return valid;
  }
}

/** Judges a southern plate's number: the strip plates of Hadhramaut, Al Mahrah,
 * Shabwah and Marib, Aden's and Taiz's. Gated on the serial. The artwork shows
 * three to five digits; nothing more of the grammar is published. */
export class YemenSouthernValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonSerialNotNumeric = 'The number is digits only.';
  static readonly reasonSerialLength = 'The number is three to five digits.';
  static readonly minSerialLength = 3;
  static readonly maxSerialLength = 5;

  judge(entry: PlateEntry): PlateValidation {
    return YemenSouthernValidator.validateFields({ serial: entry.group('serial') });
  }

  static validateFields({ serial }: { serial: string }): PlateValidation {
    if (serial.length < YemenSouthernValidator.minSerialLength || serial.length > YemenSouthernValidator.maxSerialLength) {
      return invalid(YemenSouthernValidator.reasonSerialLength);
    }
    if (!isDigits(serial)) {
      return invalid(YemenSouthernValidator.reasonSerialNotNumeric);
    }
    return valid;
  }
}

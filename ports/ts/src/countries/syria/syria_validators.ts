import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** A two-digit code and a five-digit serial; no code table is published, so
 * any two digits pass. */
export class SyriaTransitionalValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonCode = 'The code is two digits.';
  static readonly reasonSerial = 'The serial is five digits.';

  judge(entry: PlateEntry): PlateValidation {
    return SyriaTransitionalValidator.validateFields({ code: entry.group('code'), serial: entry.group('serial') });
  }

  static validateFields({ code, serial }: { code: string; serial: string }): PlateValidation {
    if (!isDigitsOfLength(code, 2)) {
      return invalid(SyriaTransitionalValidator.reasonCode);
    }
    if (!isDigitsOfLength(serial, 5)) {
      return invalid(SyriaTransitionalValidator.reasonSerial);
    }
    return valid;
  }
}

/** Six digits, printed twice. */
export class AanesValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonSerial = 'The number is six digits.';

  judge(entry: PlateEntry): PlateValidation {
    return AanesValidator.validateFields({ serial: entry.group('serial') });
  }

  static validateFields({ serial }: { serial: string }): PlateValidation {
    return isDigitsOfLength(serial, 6) ? valid : invalid(AanesValidator.reasonSerial);
  }
}

/** One Latin letter and four digits. */
export class AanesMotorcycleValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetter = 'A motorcycle plate starts with a letter.';
  static readonly reasonSerial = 'The number is four digits.';

  private static readonly _letter = /^[A-Z]$/;

  judge(entry: PlateEntry): PlateValidation {
    return AanesMotorcycleValidator.validateFields({ letter: entry.group('letter'), serial: entry.group('serial') });
  }

  static validateFields({ letter, serial }: { letter: string; serial: string }): PlateValidation {
    if (!AanesMotorcycleValidator._letter.test(letter)) {
      return invalid(AanesMotorcycleValidator.reasonLetter);
    }
    if (!isDigitsOfLength(serial, 4)) {
      return invalid(AanesMotorcycleValidator.reasonSerial);
    }
    return valid;
  }
}

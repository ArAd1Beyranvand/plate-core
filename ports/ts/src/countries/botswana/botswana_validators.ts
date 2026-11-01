import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a private or public plate (`B 123 ABC`): the letter B, three digits
 * and three letters, none of them Q. Reports, never bars a keystroke. */
export class BotswanaValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonPrefix = 'The prefix is B.';
  static readonly reasonSerial = 'The number is three digits.';
  static readonly reasonSuffix = 'The register is three letters, never Q.';

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('prefix') !== 'B') {
      return invalid(BotswanaValidator.reasonPrefix);
    }
    if (!isDigitsOfLength(entry.group('serial'), 3)) {
      return invalid(BotswanaValidator.reasonSerial);
    }
    if (!BotswanaValidator._register.test(entry.group('suffix'))) {
      return invalid(BotswanaValidator.reasonSuffix);
    }
    return valid;
  }

  private static readonly _register = /^[A-PR-Z]{3}$/;
}

/** Judges a government plate (`BX 123456`): the prefix BX and six digits. */
export class BotswanaGovernmentValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonPrefix = 'The prefix is BX.';
  static readonly reasonSerial = 'The number is six digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('prefix') !== 'BX') {
      return invalid(BotswanaGovernmentValidator.reasonPrefix);
    }
    if (!isDigitsOfLength(entry.group('serial'), 6)) {
      return invalid(BotswanaGovernmentValidator.reasonSerial);
    }
    return valid;
  }
}

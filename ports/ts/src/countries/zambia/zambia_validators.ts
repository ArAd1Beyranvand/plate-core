import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges the plate (`ADD 4077 T`): three letters, four digits, one letter.
 * Reports, never bars a keystroke. */
export class ZambiaValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonPrefix = 'The prefix is three letters.';
  static readonly reasonSerial = 'The number is four digits.';
  static readonly reasonSuffix = 'The suffix is one letter.';

  static readonly _prefix = new RegExp('^[A-Z]{3}$');
  static readonly _suffix = new RegExp('^[A-Z]$');

  judge(entry: PlateEntry): PlateValidation {
    if (!ZambiaValidator._prefix.test(entry.group('prefix'))) {
      return invalid(ZambiaValidator.reasonPrefix);
    }
    if (!isDigitsOfLength(entry.group('serial'), 4)) {
      return invalid(ZambiaValidator.reasonSerial);
    }
    if (!ZambiaValidator._suffix.test(entry.group('suffix'))) {
      return invalid(ZambiaValidator.reasonSuffix);
    }
    return valid;
  }
}

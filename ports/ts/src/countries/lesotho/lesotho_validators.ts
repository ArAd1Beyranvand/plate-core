import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Advisory validator for `A 1705`: one or two letters, four digits. */
export class LesothoValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly _letters = new RegExp('^[A-Z]{1,2}$');

  static readonly reasonLetters = 'The prefix is one or two letters.';
  static readonly reasonSerial = 'The number is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!LesothoValidator._letters.test(entry.group('letters'))) {
      return invalid(LesothoValidator.reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('serial'), 4)) {
      return invalid(LesothoValidator.reasonSerial);
    }
    return valid;
  }
}

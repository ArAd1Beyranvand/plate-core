import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a government plate (`GM 3345`): two letters and four digits.
 * Reports, never bars a keystroke. */
export class MauritiusValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The prefix is two letters.';
  static readonly reasonSerial = 'The number is four digits.';
  static readonly _letters = new RegExp('^[A-Z]{2}$');

  judge(entry: PlateEntry): PlateValidation {
    if (!MauritiusValidator._letters.test(entry.group('letters'))) {
      return invalid(MauritiusValidator.reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('serial'), 4)) {
      return invalid(MauritiusValidator.reasonSerial);
    }
    return valid;
  }
}

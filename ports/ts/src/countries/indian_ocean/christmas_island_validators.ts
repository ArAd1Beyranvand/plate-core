import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a `CI•1234` value: a two-letter register then a four-digit serial
 * (leading zeros are printed). Reports, never bars a keystroke. */
export class ChristmasIslandValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The register is two letters.';
  static readonly reasonSerial = 'The number is four digits.';
  static readonly _letters = new RegExp('^[A-Z]{2}$');

  judge(entry: PlateEntry): PlateValidation {
    if (!ChristmasIslandValidator._letters.test(entry.group('letters'))) {
      return invalid(ChristmasIslandValidator.reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('serial'), 4)) {
      return invalid(ChristmasIslandValidator.reasonSerial);
    }
    return valid;
  }
}

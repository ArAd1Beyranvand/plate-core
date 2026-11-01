import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Djibouti registration: three digits, the letter `D`, two digits
 * (`683 D 30`). The article gives no format table, so this is the one
 * reference plate; it reports and never bars a keystroke. */
export class DjiboutiValidator extends GatedPlateValidator {
  readonly gateGroup = 'code';

  static readonly reasonNumber = 'The number is three digits.';
  static readonly reasonLetter = 'The letter is D.';
  static readonly reasonCode = 'The code is two digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('number'), 3)) {
      return invalid(DjiboutiValidator.reasonNumber);
    }
    if (entry.group('letter') !== 'D') {
      return invalid(DjiboutiValidator.reasonLetter);
    }
    if (!isDigitsOfLength(entry.group('code'), 2)) {
      return invalid(DjiboutiValidator.reasonCode);
    }
    return valid;
  }
}

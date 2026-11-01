import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges `ER`, a digit in the disc and a five-digit number (`ER – 3  01860`).
 * Only one reference plate exists, so the rules are its shape. Reports, never
 * bars a keystroke. */
export class EritreaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonCode = 'The disc holds one digit.';
  static readonly reasonNumber = 'The number is five digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('code'), 1)) {
      return invalid(EritreaValidator.reasonCode);
    }
    if (!isDigitsOfLength(entry.group('number'), 5)) {
      return invalid(EritreaValidator.reasonNumber);
    }
    return valid;
  }
}

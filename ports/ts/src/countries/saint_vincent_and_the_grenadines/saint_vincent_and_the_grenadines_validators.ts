import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Vincentian plate: one letter and four digits (`A 1234`).
 * Reports, never bars a keystroke. */
export class SaintVincentAndTheGrenadinesValidator extends GatedPlateValidator {
  readonly gateGroup = 'digits';

  static readonly reason = 'A plate is one letter and four digits.';

  private static readonly _letter = /^[A-Z]$/;

  judge(entry: PlateEntry): PlateValidation {
    return isDigitsOfLength(entry.group('digits'), 4) && SaintVincentAndTheGrenadinesValidator._letter.test(entry.group('letters'))
      ? valid
      : invalid(SaintVincentAndTheGrenadinesValidator.reason);
  }
}

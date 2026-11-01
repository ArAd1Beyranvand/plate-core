import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Wallis and Futuna plate: a four-digit serial followed by the
 * printed `WF`. Reports, never bars a keystroke. */
export class WallisAndFutunaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonNumber = 'The serial is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('number'), 4)) {
      return invalid(WallisAndFutunaValidator.reasonNumber);
    }
    return valid;
  }
}

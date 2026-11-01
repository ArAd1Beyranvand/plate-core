import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges an Order of Malta plate: the prefix `SMOM` and a two-digit number.
 * Reports, never bars a keystroke. The article gives no number range; two
 * digits is what the one photographed plate shows. */
export class SovereignMilitaryOrderOfMaltaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonPrefix = 'The prefix is SMOM.';
  static readonly reasonNumber = 'The number is two digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('prefix') !== 'SMOM') {
      return invalid(SovereignMilitaryOrderOfMaltaValidator.reasonPrefix);
    }
    if (!isDigitsOfLength(entry.group('number'), 2)) {
      return invalid(SovereignMilitaryOrderOfMaltaValidator.reasonNumber);
    }
    return valid;
  }
}

import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/**
 * Judges a French Polynesia plate: six digits and one letter, as in
 * `233051 P`. The letter leaves out I, O and U. Reports, never bars a
 * keystroke.
 */
export class FrenchPolynesiaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonNumber = 'The number is six digits.';
  static readonly reasonLetter = 'The letter is one of A–Z without I, O, U.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('number'), 6)) return invalid(FrenchPolynesiaValidator.reasonNumber);
    if (!/^[A-HJ-NP-TV-Z]$/.test(entry.group('letter'))) return invalid(FrenchPolynesiaValidator.reasonLetter);
    return valid;
  }
}

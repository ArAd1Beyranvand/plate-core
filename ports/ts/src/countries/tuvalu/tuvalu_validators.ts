import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Tuvalu plate by its groups: `letters` (two) and `serial` (four
/// digits), `AB 1234`. Reports, never bars a keystroke. */
export class TuvaluValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The register is two letters.';
  static readonly reasonSerial = 'The number is four digits.';
  static readonly _letters = new RegExp('^[A-Z]{2}$');

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('letters').length > 0 && !TuvaluValidator._letters.test(entry.group('letters'))) {
      return invalid(TuvaluValidator.reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('serial'), 4)) {
      return invalid(TuvaluValidator.reasonSerial);
    }
    return valid;
  }
}

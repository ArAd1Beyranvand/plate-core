import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a 2006 plate: three letters and four digits (`ABC 1234`). Reports,
/// never bars a keystroke. */
export class ZimbabweValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The register is three letters.';
  static readonly reasonSerial = 'The number is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    const letters = entry.group('letters');
    if (letters.length !== 3 || !/^[A-Z]{3}$/.test(letters)) {
      return invalid(ZimbabweValidator.reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('serial'), 4)) {
      return invalid(ZimbabweValidator.reasonSerial);
    }
    return valid;
  }
}

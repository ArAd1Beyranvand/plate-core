import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Malawian plate: two letters and four digits (`BC 5049`). Reports,
/// never bars a keystroke. */
export class MalawiValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The register is two letters.';
  static readonly reasonSerial = 'The number is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!/^[A-Z]{2}$/.test(entry.group('letters'))) {
      return invalid(MalawiValidator.reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('serial'), 4)) {
      return invalid(MalawiValidator.reasonSerial);
    }
    return valid;
  }
}

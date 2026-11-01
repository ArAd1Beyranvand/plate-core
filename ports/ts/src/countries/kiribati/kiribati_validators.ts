import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Kiribati plate by its groups: `letters` (three) and `serial`
/// (three digits), `ABC 123`. Reports, never bars a keystroke. */
export class KiribatiValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The register is three letters.';
  static readonly reasonSerial = 'The number is three digits.';

  private static readonly _letters = /^[A-Z]{3}$/;

  judge(entry: PlateEntry): PlateValidation {
    const letters = entry.group('letters');
    if (letters && !KiribatiValidator._letters.test(letters)) {
      return invalid(KiribatiValidator.reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('serial'), 3)) {
      return invalid(KiribatiValidator.reasonSerial);
    }
    return valid;
  }
}

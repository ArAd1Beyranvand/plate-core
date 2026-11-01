import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a plate by its groups: `letters` (one, `C`) and `serial` (three
/// digits), `C 400`. Reports, never bars a keystroke. */
export class CocosKeelingIslandsValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The register is the letter C.';
  static readonly reasonSerial = 'The number is three digits.';

  judge(entry: PlateEntry): PlateValidation {
    const letters = entry.group('letters');
    if (letters.length > 0 && letters !== 'C') {
      return invalid(CocosKeelingIslandsValidator.reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('serial'), 3)) {
      return invalid(CocosKeelingIslandsValidator.reasonSerial);
    }
    return valid;
  }
}

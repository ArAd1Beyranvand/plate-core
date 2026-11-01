import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges an `ABC 123` plate: groups `letters` (three Latin capitals) and
 * `number` (three digits). Reports, never bars a keystroke. */
export class EasterIslandValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonLetters = 'The plate starts with three letters.';
  static readonly reasonNumber = 'The number is three digits.';
  private static readonly _letters = new RegExp(String.raw`^[A-Z]{3}$`);

  judge(entry: PlateEntry): PlateValidation {
    if (!EasterIslandValidator._letters.test(entry.group('letters'))) {
      return invalid(EasterIslandValidator.reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('number'), 3)) {
      return invalid(EasterIslandValidator.reasonNumber);
    }
    return valid;
  }
}

import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a Saint Martin plate: three or four digits, then two or three
 * letters (`1234-ABC`, `123-AB`). The letters leave out I, O, U and the SS
 * pair. Reports, never bars a keystroke. */
export class CollectivityOfSaintMartinValidator extends GatedPlateValidator {
  readonly gateGroup = 'letters';

  static readonly reasonNumber = 'The number is three or four digits.';
  static readonly reasonLetters = 'The letters are two or three (no I, O, U or SS).';

  private static readonly _number = new RegExp(String.raw`^\d{3,4}$`);
  private static readonly _letters = new RegExp(String.raw`^[A-HJ-NP-TV-Z]{2,3}$`);

  judge(entry: PlateEntry): PlateValidation {
    if (!CollectivityOfSaintMartinValidator._number.test(entry.group('number'))) {
      return invalid(CollectivityOfSaintMartinValidator.reasonNumber);
    }
    const letters = entry.group('letters');
    if (!CollectivityOfSaintMartinValidator._letters.test(letters) || letters.includes('SS')) {
      return invalid(CollectivityOfSaintMartinValidator.reasonLetters);
    }
    return valid;
  }
}

import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges AA-##-##-AA: a two-letter region code, two pairs of digits and two
 * letters. Reports, never bars a keystroke. */
export class AngolaValidator extends GatedPlateValidator {
  readonly gateGroup = 'suffix';

  static readonly reasonRegion = 'The region is two letters.';
  static readonly reasonDigits = 'The number is two pairs of digits.';
  static readonly reasonSuffix = 'The series is two letters.';

  private static readonly _pair = new RegExp(String.raw`^[A-Z]{2}$`);

  private static _letters(s: string): boolean {
    return AngolaValidator._pair.test(s);
  }

  judge(entry: PlateEntry): PlateValidation {
    if (!AngolaValidator._letters(entry.group('region'))) {
      return invalid(AngolaValidator.reasonRegion);
    }
    if (!isDigitsOfLength(entry.group('first'), 2) ||
        !isDigitsOfLength(entry.group('second'), 2)) {
      return invalid(AngolaValidator.reasonDigits);
    }
    if (!AngolaValidator._letters(entry.group('suffix'))) {
      return invalid(AngolaValidator.reasonSuffix);
    }
    return valid;
  }
}

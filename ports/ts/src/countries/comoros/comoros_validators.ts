import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a `ComorosPlates` value: three or four digits, a letter and two
 * digits (`1284 A 73`, `079 U 73`). Reports, never bars a keystroke. The shape
 * is read off the plates in the article and the photographs found; nothing
 * found says what the letter or the last two digits (`71` and `73` were
 * seen) stand for, so no allocation rules are checked. */
export class ComorosPlateValidator extends GatedPlateValidator {
  readonly gateGroup = 'code';

  static readonly reasonNumber = 'The number is three or four digits.';
  static readonly reasonSeries = 'The series is one letter.';
  static readonly reasonCode = 'The code is two digits.';

  private static readonly _number = new RegExp(String.raw`^[0-9]{3,4}$`);
  private static readonly _series = new RegExp(String.raw`^[A-Z]$`);
  private static readonly _code = new RegExp(String.raw`^[0-9]{2}$`);

  judge(entry: PlateEntry): PlateValidation {
    if (!ComorosPlateValidator._number.test(entry.group('number'))) {
      return invalid(ComorosPlateValidator.reasonNumber);
    }
    if (!ComorosPlateValidator._series.test(entry.group('series'))) {
      return invalid(ComorosPlateValidator.reasonSeries);
    }
    if (!ComorosPlateValidator._code.test(entry.group('code'))) {
      return invalid(ComorosPlateValidator.reasonCode);
    }
    return valid;
  }
}

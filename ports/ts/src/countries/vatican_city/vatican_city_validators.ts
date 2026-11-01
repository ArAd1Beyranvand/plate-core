import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a Vatican plate: `CV` (resident) or `SCV` (State) followed by
 * digits, and on an official plate one trailing letter. Reports, never bars
 * a keystroke. */
export class VaticanCityValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonPrefix = 'The prefix is CV or SCV.';
  static readonly reasonNumber = 'The number is digits.';
  static readonly reasonSuffix = 'The suffix is one letter.';

  private static readonly _digits = new RegExp(String.raw`^[0-9]+$`);
  private static readonly _letter = new RegExp(String.raw`^[A-Z]$`);

  judge(entry: PlateEntry): PlateValidation {
    const prefix = entry.group('prefix');
    if (prefix !== 'CV' && prefix !== 'SCV') {
      return invalid(VaticanCityValidator.reasonPrefix);
    }
    if (!VaticanCityValidator._digits.test(entry.group('number'))) {
      return invalid(VaticanCityValidator.reasonNumber);
    }
    const suffix = entry.group('suffix');
    if (suffix.length > 0 && !VaticanCityValidator._letter.test(suffix)) {
      return invalid(VaticanCityValidator.reasonSuffix);
    }
    return valid;
  }
}

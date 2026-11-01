import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/** Judges a `SintMaartenPlates.private` value: a one- or two-letter type
 * prefix and up to four digits (`P 2404`, `TX 123`). Reports, never bars a
 * keystroke. */
export class SintMaartenValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly _prefix = new RegExp(String.raw`^[A-Z]{1,2}$`);

  static readonly reasonPrefix = 'The prefix is one or two letters.';
  static readonly reasonNumber = 'The number is up to four digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!SintMaartenValidator._prefix.test(entry.group('prefix'))) {
      return invalid(SintMaartenValidator.reasonPrefix);
    }
    const number = entry.group('number');
    if (number === '' || number.length > 4 || !isDigits(number)) {
      return invalid(SintMaartenValidator.reasonNumber);
    }
    return valid;
  }
}

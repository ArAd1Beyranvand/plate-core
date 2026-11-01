import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a San Marino plate: a `prefix` of one to seven letters (a single
 * letter on a private plate; `CD`, `CRS`, `VE`, `POLIZIA` on the coded ones)
 * and a `number` of one to four digits. Reports, never bars a keystroke. */
export class SanMarinoValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonPrefix = 'The prefix is one to seven letters.';
  static readonly reasonNumber = 'The number is one to four digits.';

  private static readonly _prefix = /^[A-Z]{1,7}$/;
  private static readonly _number = /^[0-9]{1,4}$/;

  judge(entry: PlateEntry): PlateValidation {
    if (!SanMarinoValidator._prefix.test(entry.group('prefix'))) {
      return invalid(SanMarinoValidator.reasonPrefix);
    }
    if (!SanMarinoValidator._number.test(entry.group('number'))) {
      return invalid(SanMarinoValidator.reasonNumber);
    }
    return valid;
  }
}

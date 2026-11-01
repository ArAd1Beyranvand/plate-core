import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a `SomaliaPlates` value, two letters and four digits (`AD 4657`).
 * Reports, never bars a keystroke. The shape is read off the one documented
 * plate; the article gives no allocation rules, so none are checked. */
export class SomaliaPlateValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonSeries = 'The series is two letters.';
  static readonly reasonNumber = 'The number is four digits.';

  private static readonly _series = new RegExp(String.raw`^[A-Z]{2}$`);
  private static readonly _number = new RegExp(String.raw`^[0-9]{4}$`);

  judge(entry: PlateEntry): PlateValidation {
    if (!SomaliaPlateValidator._series.test(entry.group('series'))) {
      return invalid(SomaliaPlateValidator.reasonSeries);
    }
    if (!SomaliaPlateValidator._number.test(entry.group('number'))) {
      return invalid(SomaliaPlateValidator.reasonNumber);
    }
    return valid;
  }
}

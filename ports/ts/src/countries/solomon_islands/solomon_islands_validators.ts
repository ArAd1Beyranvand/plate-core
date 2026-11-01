import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a `SolomonIslandsPlates.private` value: two letters and four digits (`MA 5021`). Reports, never bars. */
export class SolomonIslandsValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly _series = new RegExp(String.raw`^[A-Z]{2}$`);

  static readonly reasonSeries = 'The series is two letters.';
  static readonly reasonSerial = 'The serial is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!SolomonIslandsValidator._series.test(entry.group('series'))) {
      return invalid(SolomonIslandsValidator.reasonSeries);
    }
    if (!isDigitsOfLength(entry.group('serial'), 4)) {
      return invalid(SolomonIslandsValidator.reasonSerial);
    }
    return valid;
  }
}

import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** A two-letter series (`UP` police, `UU` prisons) and a serial of four or
  five digits. Reports, never bars a keystroke. */
export class UgandaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonSeries = 'The series is two letters.';
  static readonly reasonNumber = 'The number is four or five digits.';

  private static readonly _series = /^[A-Z]{2}$/;
  private static readonly _number = /^[0-9]{4,5}$/;

  judge(entry: PlateEntry): PlateValidation {
    if (!UgandaValidator._series.test(entry.group('series')!)) {
      return invalid(UgandaValidator.reasonSeries);
    }
    if (!UgandaValidator._number.test(entry.group('number')!)) {
      return invalid(UgandaValidator.reasonNumber);
    }
    return valid;
  }
}

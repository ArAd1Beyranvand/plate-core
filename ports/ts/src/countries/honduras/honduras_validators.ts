import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a 2018 plate: a class letter (`H`; `B` for motorcycles), two series
 * letters and four digits (`HAB 0123`). Reports, never bars a keystroke. */
export class HondurasValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonClass = 'The class is one letter.';
  static readonly reasonSeries = 'The series is two letters.';
  static readonly reasonSerial = 'The number is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!/^[A-Z]$/.test(entry.group('class')!)) {
      return invalid(HondurasValidator.reasonClass);
    }
    if (!/^[A-Z]{2}$/.test(entry.group('series')!)) {
      return invalid(HondurasValidator.reasonSeries);
    }
    if (!isDigitsOfLength(entry.group('serial')!, 4)) {
      return invalid(HondurasValidator.reasonSerial);
    }
    return valid;
  }
}

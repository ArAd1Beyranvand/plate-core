import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a 1976 car plate: a class letter and four digits (`P-0000`). Reports,
 * never bars a keystroke. */
export class ElSalvadorValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetter = 'The class is one letter.';
  static readonly reasonSerial = 'The number is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!new RegExp(String.raw`^[A-Z]$`).test(entry.group('letter')!)) {
      return invalid(ElSalvadorValidator.reasonLetter);
    }
    if (!isDigitsOfLength(entry.group('serial')!, 4)) {
      return invalid(ElSalvadorValidator.reasonSerial);
    }
    return valid;
  }
}

/** Judges a 1976 motorcycle plate: a letter, one digit and three digits
 * (`M-1-234`). */
export class ElSalvadorMotorcycleValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetter = 'The class is one letter.';
  static readonly reasonSeries = 'The series is one digit.';
  static readonly reasonSerial = 'The number is three digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!new RegExp(String.raw`^[A-Z]$`).test(entry.group('letter')!)) {
      return invalid(ElSalvadorMotorcycleValidator.reasonLetter);
    }
    if (!isDigitsOfLength(entry.group('series')!, 1)) {
      return invalid(ElSalvadorMotorcycleValidator.reasonSeries);
    }
    if (!isDigitsOfLength(entry.group('serial')!, 3)) {
      return invalid(ElSalvadorMotorcycleValidator.reasonSerial);
    }
    return valid;
  }
}

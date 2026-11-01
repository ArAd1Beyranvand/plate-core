import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** A fixed `T`, three digits, three letters; the organisation plate is `T`, a
 * three-digit code (200 to 399), `CD` and a three-digit number. Reports,
 * never bars a keystroke. */
export class TanzaniaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonNumber = 'The number is three digits.';
  static readonly reasonLetters = 'The series is three letters.';
  static readonly reasonCode = 'The organisation code is 200 to 399.';
  static readonly reasonCar = 'The car number is three digits.';

  private static readonly _code = new RegExp(String.raw`^[23][0-9]{2}$`);
  private static readonly _letters = new RegExp(String.raw`^[A-Z]{3}$`);

  judge(entry: PlateEntry): PlateValidation {
    const organisation = entry.group('organisation');
    if (organisation !== undefined && organisation.length > 0) {
      if (!TanzaniaValidator._code.test(organisation)) {
        return invalid(TanzaniaValidator.reasonCode);
      }
      if (!isDigitsOfLength(entry.group('number'), 3)) {
        return invalid(TanzaniaValidator.reasonCar);
      }
      return valid;
    }
    if (!isDigitsOfLength(entry.group('number'), 3)) {
      return invalid(TanzaniaValidator.reasonNumber);
    }
    if (!TanzaniaValidator._letters.test(entry.group('letters'))) {
      return invalid(TanzaniaValidator.reasonLetters);
    }
    return valid;
  }
}

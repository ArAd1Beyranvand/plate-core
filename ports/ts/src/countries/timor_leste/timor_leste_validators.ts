import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** A current plate: five digits as `NN·NNN`, and on a government plate the
 * letter `G`. No ranges are published, so none are checked. Reports, never
 * bars. */
export class TimorLesteValidator extends GatedPlateValidator {
  readonly gateGroup = 'second';

  static readonly reasonDigits = 'The number is five digits, NN·NNN.';
  static readonly reasonSuffix = 'A government plate ends in G.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('first'), 2) || !isDigitsOfLength(entry.group('second'), 3)) {
      return invalid(TimorLesteValidator.reasonDigits);
    }
    const suffix = entry.group('suffix');
    if (suffix !== '' && suffix !== 'G') {
      return invalid(TimorLesteValidator.reasonSuffix);
    }
    return valid;
  }
}

/** An expiry `MMYY` (month 01-12), the code `DF`, 1-4 digits and up to two
 * letters. The expiry's year is not range-checked. */
export class TimorLesteIndonesianValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonExpiry = 'The expiry is a month 01–12 and a year.';
  static readonly reasonRegion = 'East Timor plates carry the code DF.';
  static readonly reasonNumber = 'The number is 1 to 4 digits.';

  judge(entry: PlateEntry): PlateValidation {
    const expiry = entry.group('expiry');
    const month = isDigitsOfLength(expiry, 4) ? parseInt(expiry.slice(0, 2), 10) : 0;
    if (month < 1 || month > 12) {
      return invalid(TimorLesteIndonesianValidator.reasonExpiry);
    }
    if (entry.group('prefix') !== 'DF') {
      return invalid(TimorLesteIndonesianValidator.reasonRegion);
    }
    const number = entry.group('number');
    if (number === '' || number.length > 4 || !isDigits(number)) {
      return invalid(TimorLesteIndonesianValidator.reasonNumber);
    }
    return valid;
  }
}

/** The prefix `T` or `TP` and `NN-NN`. */
export class TimorLestePortugueseValidator extends GatedPlateValidator {
  readonly gateGroup = 'second';

  static readonly reasonPrefix = 'The prefix is T or TP.';
  static readonly reasonDigits = 'The number is four digits, NN-NN.';

  judge(entry: PlateEntry): PlateValidation {
    const prefix = entry.group('prefix');
    if (prefix !== 'T' && prefix !== 'TP') {
      return invalid(TimorLestePortugueseValidator.reasonPrefix);
    }
    if (!isDigitsOfLength(entry.group('first'), 2) || !isDigitsOfLength(entry.group('second'), 2)) {
      return invalid(TimorLestePortugueseValidator.reasonDigits);
    }
    return valid;
  }
}

import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid, isLetters } from '../../core/validators/plate_validator';

const letter = /^[A-Z]$/;

/**
 * Judges a `DominicanRepublicPlates.private1990`, `passenger1980` or
 * `private1994` value: two fields of three digits (`953-147`). Reports,
 * never bars a keystroke.
 */
export class DominicanRepublicValidator extends GatedPlateValidator {
  readonly gateGroup = 'last';

  static readonly reason = 'A plate is two fields of three digits.';

  judge(entry: PlateEntry): PlateValidation {
    return isDigitsOfLength(entry.group('first'), 3) && isDigitsOfLength(entry.group('last'), 3) ? valid : invalid(DominicanRepublicValidator.reason);
  }
}

/**
 * Judges a `DominicanRepublicPlates.passenger1986` value: a letter, two
 * digits and four digits (`P06-2686`; the article gives `P01-2345`).
 */
export class DominicanRepublicLetteredValidator extends GatedPlateValidator {
  readonly gateGroup = 'tail';

  static readonly reason = 'A plate is a letter, two digits and four digits.';

  judge(entry: PlateEntry): PlateValidation {
    return letter.test(entry.group('letter')) && isDigitsOfLength(entry.group('head'), 2) && isDigitsOfLength(entry.group('tail'), 4)
      ? valid
      : invalid(DominicanRepublicLetteredValidator.reason);
  }
}

/**
 * Judges a `DominicanRepublicPlates.exempt` value: two letters and five
 * digits (`EA 01320`; the article gives `AB 01234`).
 */
export class DominicanRepublicExemptValidator extends GatedPlateValidator {
  readonly gateGroup = 'digits';

  static readonly reason = 'A plate is two letters and five digits.';

  judge(entry: PlateEntry): PlateValidation {
    return isLetters(entry.group('letters'), 2) && isDigitsOfLength(entry.group('digits'), 5) ? valid : invalid(DominicanRepublicExemptValidator.reason);
  }
}

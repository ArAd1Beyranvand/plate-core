import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a `CaymanIslandsPlates.pair` or `taxi` value: two three-digit
 * fields. Reports, never bars a keystroke. */
export class CaymanIslandsValidator extends GatedPlateValidator {
  readonly gateGroup = 'second';

  static readonly reasonDigits = 'A plate is two groups of three digits.';

  judge(entry: PlateEntry): PlateValidation {
    return isDigitsOfLength(entry.group('first'), 3) &&
        isDigitsOfLength(entry.group('second'), 3)
        ? valid
        : invalid(CaymanIslandsValidator.reasonDigits);
  }
}

/** Judges a `CaymanIslandsPlates.single` value: five digits. */
export class CaymanIslandsSingleValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonDigits = 'The serial is five digits.';

  judge(entry: PlateEntry): PlateValidation {
    return isDigitsOfLength(entry.group('serial'), 5)
        ? valid
        : invalid(CaymanIslandsSingleValidator.reasonDigits);
  }
}

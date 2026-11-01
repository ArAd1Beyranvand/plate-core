import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

const codePoints = (s: string): string[] => [...s];

/** The Lao consonants that open a plate, by the class of vehicle they mark. */
export const LaosClassLetters = {
  passengerCar: new Set(['ກ', 'ຂ', 'ຄ', 'ນ', 'ມ', 'ຣ', 'ລ', 'ວ', 'ຫ', 'ອ', 'ຮ']) as ReadonlySet<string>,
  motorbike: new Set(['ຈ', 'ຍ', 'ດ', 'ຕ', 'ທ']) as ReadonlySet<string>,
  tricycle: new Set(['ສ']) as ReadonlySet<string>,
  heavyTruck: new Set(['ບ']) as ReadonlySet<string>,
  get all(): ReadonlySet<string> {
    return new Set([...this.passengerCar, ...this.motorbike, ...this.tricycle, ...this.heavyTruck]);
  },
};

/** Judges a Lao plate: two consonants, the first a vehicle-class letter, and four digits. Reports, never bars a keystroke. */
export class LaosValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The register is two consonants.';
  static readonly reasonClass = 'The first consonant is not a vehicle-class letter.';
  static readonly reasonSerial = 'The number is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    const letters = codePoints(entry.group('letters'));
    if (letters.length !== 2) return invalid(LaosValidator.reasonLetters);
    if (!LaosClassLetters.all.has(letters[0])) return invalid(LaosValidator.reasonClass);
    return isDigitsOfLength(entry.group('serial'), 4) ? valid : invalid(LaosValidator.reasonSerial);
  }
}

/** Judges a temporary plate: two consonants, a digit and three, and an expiry date. */
export class LaosTemporaryValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The register is two consonants.';
  static readonly reasonSerial = 'The number is one digit and three.';
  static readonly reasonExpiry = 'The expiry date is 2-4-2 digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (codePoints(entry.group('letters')).length !== 2) return invalid(LaosTemporaryValidator.reasonLetters);
    if (!isDigitsOfLength(entry.group('digit'), 1) || !isDigitsOfLength(entry.group('serial'), 3)) return invalid(LaosTemporaryValidator.reasonSerial);
    if (!isDigitsOfLength(entry.group('expiryLead'), 2) || !isDigitsOfLength(entry.group('expiryYear'), 4) || !isDigitsOfLength(entry.group('expiryTail'), 2)) return invalid(LaosTemporaryValidator.reasonExpiry);
    return valid;
  }
}

/** Judges a plate with an optional two-digit code and a two-digit serial, or a four-digit serial when there is no code. */
export class LaosPrefixedValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonCode = 'The code is two digits.';
  static readonly reasonSerial = 'The number is two or four digits.';

  judge(entry: PlateEntry): PlateValidation {
    const hasCode = entry.spec.indicesOfGroup('code').length > 0;
    if (hasCode && !isDigitsOfLength(entry.group('code'), 2)) return invalid(LaosPrefixedValidator.reasonCode);
    return isDigitsOfLength(entry.group('serial'), hasCode ? 2 : 4) ? valid : invalid(LaosPrefixedValidator.reasonSerial);
  }
}

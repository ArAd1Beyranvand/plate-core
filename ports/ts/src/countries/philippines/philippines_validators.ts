import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

const lettersRe = /^[A-Z]+$/;
const allZeros = /^0+$/;
const hasLetter = /[A-Z]/;
const hasDigit = /[0-9]/;

/** The listed diplomatic mission codes: 001-035, 037-075 and 200-225 (036 is refused). */
const missionCodes: ReadonlySet<string> = new Set(
  [[1, 35], [37, 75], [200, 225]].flatMap(([lo, hi]) => Array.from({ length: hi - lo + 1 }, (_, i) => String(lo + i).padStart(3, '0'))),
);
const missionNotFound = 'COUNTRY NOT FOUND';

/**
 * Judges a `PhilippinesPlates.car` or `vintage` value. Reports, never bars a
 * keystroke; gated on the number.
 *
 * Three letters; digits never all zero (OMVSP excludes `00`, `000`, `0000`);
 * a first letter `S` is the government series, reported unless [government].
 * On a `vintage` spec the letters end in TX, TY or TZ and the year is four
 * digits. The region of a prefix is not checked: every letter is allocated.
 */
export class PhilippinesValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';
  /** The only kind of plate whose letters may start with S. */
  readonly government: boolean;

  constructor(o: { readonly government?: boolean } = {}) {
    super();
    this.government = o.government ?? false;
  }

  static readonly reasonLetters = 'A plate starts with three letters.';
  static readonly reasonNumber = 'The number is all digits.';
  static readonly reasonZero = 'The number is never all zeros.';
  static readonly reasonGovernment = 'S is reserved for government vehicles.';
  static readonly reasonVintage = 'A vintage plate ends in TX, TY or TZ.';
  static readonly reasonYear = 'The year is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    const V = PhilippinesValidator;
    const letters = entry.group('letters');
    const number = entry.group('number');
    if (letters.length !== 3 || !lettersRe.test(letters)) return invalid(V.reasonLetters);
    if (!isDigits(number)) return invalid(V.reasonNumber);
    if (allZeros.test(number)) return invalid(V.reasonZero);
    if (letters.startsWith('S') && !this.government) return invalid(V.reasonGovernment);
    if (entry.spec.indicesOfGroup('year').length > 0) {
      if (!['TX', 'TY', 'TZ'].includes(letters.slice(1))) return invalid(V.reasonVintage);
      if (!isDigitsOfLength(entry.group('year'), 4)) return invalid(V.reasonYear);
    }
    return valid;
  }
}

/**
 * Judges a `PhilippinesPlates.motorcycle` value: six characters with at least
 * one letter (the region letter) and one digit. The LTO issues "virtually any"
 * arrangement, so the order is not checked.
 */
export class PhilippinesMotorcycleValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLength = 'A motorcycle plate has six characters.';
  static readonly reasonMix = 'A motorcycle plate mixes letters and digits.';

  judge(entry: PlateEntry): PlateValidation {
    const serial = entry.group('serial');
    if (serial.length !== 6) return invalid(PhilippinesMotorcycleValidator.reasonLength);
    if (!hasLetter.test(serial) || !hasDigit.test(serial)) return invalid(PhilippinesMotorcycleValidator.reasonMix);
    return valid;
  }
}

/**
 * Judges a `PhilippinesPlates.diplomatic` value: a listed mission code and a
 * four-digit serial. Refuses `036` itself, so it holds even against a spec
 * built without the mission restriction.
 */
export class PhilippinesDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'mission';

  static readonly reasonSerial = 'The serial is four digits.';

  override validate(entry: PlateEntry): PlateValidation {
    if (entry.group('mission') === '036') return invalid(missionNotFound);
    return super.validate(entry);
  }

  judge(entry: PlateEntry): PlateValidation {
    if (!missionCodes.has(entry.group('mission'))) return invalid(missionNotFound);
    if (!isDigitsOfLength(entry.group('serial'), 4)) return invalid(PhilippinesDiplomaticValidator.reasonSerial);
    return valid;
  }
}

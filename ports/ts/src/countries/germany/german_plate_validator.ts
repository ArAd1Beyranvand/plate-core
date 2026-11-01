import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid, isLetters } from '../../core/validators/plate_validator';

/**
 * Validates a German (Kennzeichen) car plate. Demo-scoped: checks format and
 * commonly-documented forbidden combinations, not the full municipality lists
 * published by each Zulassungsbehörde. District codes are validated by shape
 * (1-3 letters) only, not by membership in the real Unterscheidungszeichen.
 */

/** Nationwide-forbidden letter pairs (Nazi-organisation abbreviations) plus widely-documented state-level additions and generically-offensive pairs. */
const forbiddenLetterPairs: ReadonlySet<string> = new Set(['SS', 'SA', 'KZ', 'HJ', 'NS', 'AH', 'HH', 'SD', 'IS']);

/** Digit strings commonly barred for the same reason. */
const forbiddenNumbers: ReadonlySet<string> = new Set(['88', '18', '14']);

/**
 * The area code may carry an umlaut; the identifier may not. An umlaut in the
 * identifier is the conventional marker of a deliberately fictitious plate, so
 * the asymmetry between these two patterns is the rule, not an oversight.
 *
 * All 26 Latin letters are legal in the identifier. B, F and G were barred
 * until 1992 and I, O and Q until 2000 — to keep B/8, F/E, G/6, I/1 and O/Q/0
 * apart — but that restriction is long gone, and a validator still enforcing
 * it would reject a quarter-century of real plates.
 */
const districtPattern = /^[A-ZÄÖÜ]{1,3}$/;

/** The issued identifier shapes: letters, then the digit-count range. */
const identifierShapes: readonly (readonly [number, number, number])[] = [
  [1, 1, 3],
  [2, 1, 2],
  [2, 3, 3],
  [1, 4, 4],
  [2, 4, 4],
];

function districtAndSerialError(district: string, serial: string): PlateValidation | null {
  if (!districtPattern.test(district)) return invalid('District code must be 1-3 letters.');
  if (!isDigits(serial)) return invalid('The number must be digits.');
  return null;
}

const opening = (serial: string): string => serial.slice(0, 2);

/** Validates a German car-plate district code + identifier pair. */
export class GermanPlateValidator extends GatedPlateValidator {
  readonly gateGroup = 'letters';

  /** Validates groups: district, letters, and serial. Quiet while letters are empty (do not flag incomplete plates). */
  judge(entry: PlateEntry): PlateValidation {
    const registration = GermanPlateValidator.validateFields({
      district: entry.group('district'),
      identifierLetters: entry.group('letters'),
      identifierDigits: entry.group('serial'),
    });
    if (registration.reason !== null) return registration;
    // Empty on every spec that has no season block, so this costs a seasonal plate a check and an ordinary one nothing.
    return GermanPlateValidator.validateSeason({ start: entry.group('seasonStart'), end: entry.group('seasonEnd') });
  }

  /** Two months of validity (e.g., 03–10 for spring/fall). No order required: 11–03 is valid (winter). Quiet about incomplete months (e.g., '0'). */
  static validateSeason({ start, end }: { start: string; end: string }): PlateValidation {
    for (const month of [start, end]) {
      if (month.length < 2) continue;
      if (!isDigitsOfLength(month, 2)) return invalid('A season month is two digits.');
      const value = Number(month);
      if (value < 1 || value > 12) return invalid(`"${month}" is not a month.`);
    }
    return valid;
  }

  static validateFields({ district, identifierLetters, identifierDigits }: { district: string; identifierLetters: string; identifierDigits: string }): PlateValidation {
    const d = district.toUpperCase();
    const letters = identifierLetters.toUpperCase();
    const digits = identifierDigits;
    if (!districtPattern.test(d)) return invalid('District code must be 1-3 letters.');
    if (!isLetters(letters, 1, 2)) return invalid('Identifier letters must be 1-2 letters.');
    if (digits !== '' && !(isDigits(digits) && digits.length <= 4)) return invalid('Identifier digits must be 1-4 digits.');
    if (digits.startsWith('0')) return invalid('The serial cannot start with 0.');
    if (d.length + letters.length + digits.length > 8) return invalid('Plate exceeds the 8-character maximum.');
    if (digits !== '' && !identifierShapes.some(([l, min, max]) => l === letters.length && digits.length >= min && digits.length <= max)) {
      return invalid(`${letters.length} letter(s) and ${digits.length} digit(s) is not an issued identifier shape.`);
    }
    if (forbiddenLetterPairs.has(letters)) return invalid(`"${letters}" is a forbidden combination.`);
    if (d.length === 1 && letters.length === 1 && forbiddenLetterPairs.has(d + letters)) return invalid(`"${d + letters}" is a forbidden combination.`);
    if (digits !== '' && forbiddenNumbers.has(digits)) return invalid(`"${digits}" is a forbidden combination.`);
    return valid;
  }
}

/** Validates a `06` dealer or `07` collector plate: area code + 5 digits starting with 06/07. Sibling to GermanPlateValidator because these are not registrations. */
export class GermanSerialPlateValidator extends GatedPlateValidator {
  /** The two digits the serial opens with; left out, the spec decides (`de.collector` is 07, any other 06), as when the plate loader builds it with no arguments. */
  constructor(readonly prefix?: string) {
    super();
  }

  /** The `06` number a garage moves between vehicles for test drives. */
  static dealer = (): GermanSerialPlateValidator => new GermanSerialPlateValidator('06');

  /** The `07` number a collector uses across the vehicles in one collection. */
  static collector = (): GermanSerialPlateValidator => new GermanSerialPlateValidator('07');

  readonly gateGroup = 'serial';

  judge(entry: PlateEntry): PlateValidation {
    const serial = entry.group('serial');
    const error = districtAndSerialError(entry.group('district').toUpperCase(), serial);
    if (error !== null) return error;
    const prefix = this.prefix ?? (entry.spec.id === 'de.collector' ? '07' : '06');
    if (!prefix.startsWith(opening(serial))) return invalid(`This number begins "${prefix}".`);
    return serial.length > 5 ? invalid('The number is five digits.') : valid;
  }
}

/** Validates a `04` short-term or export plate: area code + 5 digits (opening 04 for short-term) + expiry date. Sibling to GermanPlateValidator. */
export class GermanDatedPlateValidator extends GatedPlateValidator {
  /** The two digits the number opens with, or null when the format reserves none; left out, the spec decides (only `de.shortterm` reserves 04). */
  constructor(readonly prefix?: string | null) {
    super();
  }

  /** The `04` number, valid for at most four weeks. Its serial opens `04`. */
  static shortTerm = (): GermanDatedPlateValidator => new GermanDatedPlateValidator('04');

  /** The export number, valid for at most a year. Its serial is not reserved to an opening pair, so there is nothing to check it against. */
  static export = (): GermanDatedPlateValidator => new GermanDatedPlateValidator(null);

  readonly gateGroup = 'expiryDay';

  judge(entry: PlateEntry): PlateValidation {
    const serial = entry.group('serial');
    const error = districtAndSerialError(entry.group('district').toUpperCase(), serial);
    if (error !== null) return error;
    const prefix = this.prefix === undefined ? (entry.spec.id === 'de.shortterm' ? '04' : null) : this.prefix;
    if (prefix !== null && !prefix.startsWith(opening(serial))) return invalid(`This number begins "${prefix}".`);
    if (serial.length > 5) return invalid('The number is five digits.');
    return GermanDatedPlateValidator.validateExpiry({ day: entry.group('expiryDay'), month: entry.group('expiryMonth'), year: entry.group('expiryYear') });
  }

  /** DD/MM/YY on the band. Quiet on incomplete fields. Checks day against month length, but treats February as having 29 days (ambiguous century). */
  static validateExpiry({ day, month, year }: { day: string; month: string; year: string }): PlateValidation {
    for (const [name, value] of [['day', day], ['month', month], ['year', year]]) {
      if (value.length < 2) continue;
      if (!isDigitsOfLength(value, 2)) return invalid(`The expiry ${name} is two digits.`);
    }
    if (month.length === 2 && isDigits(month)) {
      const m = Number(month);
      if (m < 1 || m > 12) return invalid(`"${month}" is not a month.`);
      if (day.length === 2 && isDigits(day)) {
        const d = Number(day);
        if (d < 1 || d > GermanDatedPlateValidator.daysInMonth[m - 1]) return invalid(`"${day}" is not a day of month ${month}.`);
      }
    } else if (day.length === 2 && isDigits(day)) {
      const d = Number(day);
      if (d < 1 || d > 31) return invalid(`"${day}" is not a day.`);
    }
    return valid;
  }

  private static readonly daysInMonth: readonly number[] = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
}

/** Validates a Bundeswehr `Y` plate: `Y` in the area code, then six digits. */
export class GermanBundeswehrValidator extends GatedPlateValidator {
  readonly gateGroup = 'serialTail';

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('district').toUpperCase() !== 'Y') return invalid('A Bundeswehr plate begins "Y".');
    const serial = entry.group('serial') + entry.group('serialTail');
    if (!isDigits(serial)) return invalid('The number must be digits.');
    return serial.length > 6 ? invalid('The number is six digits.') : valid;
  }
}

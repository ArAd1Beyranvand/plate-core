import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

const codes = (list: string): string[] => list.split(' ');

/** Every region code Armenia issues: the provinces' and the individual plates'. Every `01`–`99` is allocated, so this is a membership test, to keep a future deallocation a change to the tables. */
const issuedRegions: ReadonlySet<string> = new Set([
  // Yerevan, Armavir, Shirak, Aragatsotn, Gegharkunik, Kotayk, Vayots Dzor, Ararat, Lori, Syunik, Tavush
  ...codes('01 02 03 04 05 06 07 08 09 10 11 13 19 61 62 63 64 65 66 67 68'),
  ...codes('12 27 28 29'),
  ...codes('14 45 46 47 48 49'),
  ...codes('15 21 22 23 24'),
  ...codes('16 31 32 33 34 35'),
  ...codes('17 42 43'),
  ...codes('18 56'),
  ...codes('25 26'),
  ...codes('36 37 38 39 41'),
  ...codes('51 52 53 54'),
  ...codes('57 58 59'),
  // Individual plates, which do not show a province.
  ...codes('20 30 40 44 50 55 60'),
  ...Array.from({ length: 31 }, (_, i) => String(69 + i)),
]);

/** Letters issued only to the state: `G` and `I` (2015), for the Police and Prosecutor's office, always doubled. */
const stateVehiclesOnly: ReadonlySet<string> = new Set(['G', 'I']);

/** When each letter entered general civilian use, as [year, month]. */
const introduced: Readonly<Record<string, readonly [number, number]>> = {
  L: [1996, 1], U: [1996, 1], S: [1996, 1], O: [1996, 1],
  P: [2008, 12],
  D: [2012, 7], N: [2012, 7], T: [2012, 7], V: [2012, 7],
  A: [2012, 5], M: [2012, 5], Q: [2012, 5], R: [2012, 5],
  C: [2013, 10], F: [2013, 10], Z: [2013, 10],
  G: [2015, 1], I: [2015, 1],
  X: [2016, 1],
  B: [2017, 1], H: [2017, 1],
  J: [2018, 1],
  W: [2019, 1], Y: [2019, 1], K: [2019, 1], E: [2019, 1],
};

/** Whether `letter` (case-insensitive) was issued by `month` of `year`. */
function inUseOn(letter: string, year: number, month: number): boolean {
  const start = introduced[letter.toUpperCase()];
  return start !== undefined && (year > start[0] || (year === start[0] && month >= start[1]));
}

const range = (from: number, to: number): string[] => Array.from({ length: to - from + 1 }, (_, i) => String(from + i).padStart(2, '0'));

/**
 * The table of reserved combinations: a letter pair and tail that names an
 * institution on a public number (`### LL ##`). Membership in the table, not
 * shape, makes the number valid. One row per combination; a null `tails`
 * allows any digits, and the Police's `ՈՍ` is left out because its `Ո` has no
 * Latin key, so no entry can match it.
 */
const specialPlates: readonly { readonly letters: string; readonly tails: readonly string[] | null }[] = [
  { letters: 'OS', tails: ['01'] }, // Constitutional Court
  { letters: 'UU', tails: ['01'] }, // Presidential Administration
  { letters: 'OO', tails: range(1, 11) }, // National Assembly
  { letters: 'FF', tails: ['01'] }, // Government
  { letters: 'LL', tails: ['03', '50', '55', '60', '70'] }, // Government
  { letters: 'SS', tails: ['03', '60'] }, // Government
  { letters: 'VV', tails: ['01'] }, // Government
  { letters: 'NN', tails: ['01'] }, // Security Council
  { letters: 'GG', tails: ['01'] }, // General Prosecutor's office
  { letters: 'II', tails: null }, // Police
  { letters: 'SL', tails: range(1, 33) }, // Banks
  { letters: 'SS', tails: ['01'] }, // Court of Cassation
  { letters: 'SS', tails: ['02'] }, // National Security Service
];

const isSpecialPlate = (letters: string, tail: string): boolean => specialPlates.some((c) => c.letters === letters.toUpperCase() && (c.tails === null || c.tails.includes(tail)));

/** Judges a civilian Armenian plate: region, two letters, serial. Reports, never bars a keystroke. */
export class ArmeniaPlateValidator extends GatedPlateValidator {
  readonly issuedYear: number | null;
  readonly issuedMonth: number;

  constructor({ issuedYear = null, issuedMonth = 12 }: { readonly issuedYear?: number | null; readonly issuedMonth?: number } = {}) {
    super();
    this.issuedYear = issuedYear;
    this.issuedMonth = issuedMonth;
  }

  readonly gateGroup = 'serial';

  judge(entry: PlateEntry): PlateValidation {
    const region = ArmeniaPlateValidator.validateRegion(entry.group('region'));
    if (region.reason !== null) return region;
    const letters = ArmeniaPlateValidator.validateLetters(entry.group('letters'), { count: 2, issuedYear: this.issuedYear, issuedMonth: this.issuedMonth });
    if (letters.reason !== null) return letters;
    return ArmeniaPlateValidator.validateSerial(entry.group('serial'), { length: 3 });
  }

  static validateRegion(region: string): PlateValidation {
    if (region.length < 2) return valid;
    if (!isDigitsOfLength(region, 2)) return invalid('A region code is two digits.');
    return issuedRegions.has(region) ? valid : invalid(`"${region}" is not a region code Armenia issues.`);
  }

  static validateLetters(letters: string, { count, issuedYear = null, issuedMonth = 12 }: { count: number; issuedYear?: number | null; issuedMonth?: number }): PlateValidation {
    const value = letters.toUpperCase();
    for (const letter of value) {
      if (!/^[A-Z]$/.test(letter)) return invalid(`"${letter}" is not a plate letter.`);
      if (stateVehiclesOnly.has(letter)) return invalid(`"${letter}" is issued to the Police and the Prosecutor's office only.`);
      if (issuedYear !== null && !inUseOn(letter, issuedYear, issuedMonth)) return invalid(`"${letter}" was not being issued in ${issuedYear}.`);
    }
    // Last, so a block still being typed is not flagged for its length.
    return value.length > count ? invalid(`The letter block is ${count} letter(s).`) : valid;
  }

  static validateSerial(serial: string, { length }: { length: number }): PlateValidation {
    if (serial !== '' && !isDigits(serial)) return invalid('The serial must be digits.');
    return serial.length > length ? invalid(`The serial is ${length} digits.`) : valid;
  }
}

/** Judges a public-institution plate: `### LL ##`, which must be a combination issued to an institution. */
export class ArmeniaPublicPlateValidator extends GatedPlateValidator {
  readonly gateGroup = 'tail';

  judge(entry: PlateEntry): PlateValidation {
    const serial = ArmeniaPlateValidator.validateSerial(entry.group('serial'), { length: 3 });
    if (serial.reason !== null) return serial;
    const letters = entry.group('letters').toUpperCase();
    const tail = entry.group('tail');
    // Quiet until both halves are complete.
    if (letters.length < 2 || tail.length < 2) return valid;
    if (!isDigitsOfLength(tail, 2)) return invalid('The last group is two digits.');
    return isSpecialPlate(letters, tail) ? valid : invalid(`"${letters} ${tail}" is not a combination issued to any institution.`);
  }
}

/** Judges a trailer plate: a serial, one letter and up to two digits below. */
export class ArmeniaTrailerPlateValidator extends GatedPlateValidator {
  readonly gateGroup = 'tail';

  judge(entry: PlateEntry): PlateValidation {
    const serial = ArmeniaPlateValidator.validateSerial(entry.group('serial'), { length: 3 });
    if (serial.reason !== null) return serial;
    const letters = ArmeniaPlateValidator.validateLetters(entry.group('letters'), { count: 1 });
    if (letters.reason !== null) return letters;
    const tail = entry.group('tail');
    if (tail !== '' && !isDigits(tail)) return invalid('The bottom row must be digits.');
    return tail.length > 2 ? invalid('The bottom row is two digits.') : valid;
  }
}

/** Judges a bus plate: four digits and `S` (city) or `L` (long-range). */
export class ArmeniaBusPlateValidator extends GatedPlateValidator {
  readonly gateGroup = 'class';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('serial'), 4)) return invalid('A bus number is four digits.');
    return ['S', 'L'].includes(entry.group('class').toUpperCase()) ? valid : invalid('A bus is "S" (city) or "L" (long-range).');
  }
}

/** Judges a diplomatic plate: a two-digit mission code, `D` (diplomat) or `T` (technician), and a serial. */
export class ArmeniaDiplomaticPlateValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  judge(entry: PlateEntry): PlateValidation {
    const mission = entry.group('mission');
    if (mission.length === 2 && !isDigitsOfLength(mission, 2)) return invalid('A mission code is two digits.');
    if (!['D', 'T'].includes(entry.group('class').toUpperCase())) return invalid('A diplomatic plate is "D" (diplomat) or "T" (technician).');
    return ArmeniaPlateValidator.validateSerial(entry.group('serial'), { length: 3 });
  }
}

/** Judges a Ministry of Defence plate: four digits and `M` (passenger) or `T` (transport), printed `Մ` and `Տ`. */
export class ArmeniaMilitaryPlateValidator extends GatedPlateValidator {
  readonly gateGroup = 'class';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('serial'), 4)) return invalid('A military number is four digits.');
    return ['M', 'T'].includes(entry.group('class').toUpperCase()) ? valid : invalid('A military plate is "Մ" (passenger) or "Տ" (transport).');
  }
}

/** Judges a plate whose only check is a serial of up to `length` digits. */
export class ArmeniaSerialPlateValidator extends GatedPlateValidator {
  readonly length: number;

  constructor({ length }: { readonly length: number }) {
    super();
    this.length = length;
  }

  readonly gateGroup = 'serial';

  judge(entry: PlateEntry): PlateValidation {
    return ArmeniaPlateValidator.validateSerial(entry.group('serial'), { length: this.length });
  }
}

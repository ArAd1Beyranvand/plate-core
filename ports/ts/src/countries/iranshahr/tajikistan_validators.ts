import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Region codes Tajikistan issues: Dushanbe, Sughd, Khatlon, Gorno-Badakhshan and the districts of republican subordination. */
const issuedRegions: ReadonlySet<string> = new Set(['01', '05', '02', '06', '03', '04', '07', '08']);

/** The closed set of letters a civilian number may carry. `H` and `P` are partners of Cyrillic `Н` and `Р` by shape, not sound. */
const plateLetters = 'ABCDEHJKMOPTXYZ';

const diplomaticClasses: readonly string[] = ['CD', 'CMD', 'D', 'T', 'S'];

/** Judges a Tajik civilian plate: region, letters, serial. Reports, never bars a keystroke. */
export class TajikistanPlateValidator extends GatedPlateValidator {
  readonly serialLength: number;
  readonly letterCount: number;
  readonly checkRegion: boolean;
  readonly gate: string;

  constructor({ serialLength = 4, letterCount = 2, checkRegion = true, gate = 'region' }: { readonly serialLength?: number; readonly letterCount?: number; readonly checkRegion?: boolean; readonly gate?: string } = {}) {
    super();
    this.serialLength = serialLength;
    this.letterCount = letterCount;
    this.checkRegion = checkRegion;
    this.gate = gate;
  }

  get gateGroup(): string {
    return this.gate;
  }

  judge(entry: PlateEntry): PlateValidation {
    if (this.checkRegion) {
      const region = TajikistanPlateValidator.validateRegion(entry.group('region'));
      if (region.reason !== null) return region;
    }
    if (this.letterCount > 0) {
      const letters = TajikistanPlateValidator.validateLetters(entry.group('letters'), { count: this.letterCount });
      if (letters.reason !== null) return letters;
    }
    return TajikistanPlateValidator.validateSerial(entry.group('serial'), { length: this.serialLength });
  }

  static validateRegion(region: string): PlateValidation {
    if (region.length < 2) return valid;
    if (!isDigitsOfLength(region, 2)) return invalid('A region code is two digits.');
    return issuedRegions.has(region) ? valid : invalid(`"${region}" is not a region code Tajikistan issues.`);
  }

  static validateLetters(letters: string, { count }: { count: number }): PlateValidation {
    const value = letters.toUpperCase();
    for (const letter of value) {
      if (!plateLetters.includes(letter)) return invalid(`"${letter}" is not a plate letter.`);
    }
    // Checked last: an in-progress group is short before it is wrong, and reporting the length first would flag every plate halfway through its letters.
    return value.length > count ? invalid(`The letter group is ${count} letter(s).`) : valid;
  }

  static validateSerial(serial: string, { length }: { length: number }): PlateValidation {
    if (serial !== '' && !isDigits(serial)) return invalid('The serial must be digits.');
    return serial.length > length ? invalid(`The serial is ${length} digits.`) : valid;
  }
}

/** Judges a foreign-registered plate: a prefix of up to three digits, one letter and a serial. */
export class TajikistanForeignPlateValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  judge(entry: PlateEntry): PlateValidation {
    const prefix = TajikistanPlateValidator.validateSerial(entry.group('prefix'), { length: 3 });
    if (prefix.reason !== null) return prefix;
    const letter = TajikistanPlateValidator.validateLetters(entry.group('letters'), { count: 1 });
    if (letter.reason !== null) return letter;
    return TajikistanPlateValidator.validateSerial(entry.group('serial'), { length: 3 });
  }
}

/** Judges a diplomatic plate: a serial, a class and a one-digit tail. */
export class TajikistanDiplomaticPlateValidator extends GatedPlateValidator {
  readonly gateGroup = 'tail';

  judge(entry: PlateEntry): PlateValidation {
    const serial = TajikistanPlateValidator.validateSerial(entry.group('serial'), { length: 3 });
    if (serial.reason !== null) return serial;
    const code = entry.group('class').toUpperCase();
    if (code !== '' && !diplomaticClasses.includes(code)) return invalid('A diplomatic class is CD, CMD, D, T or S.');
    const tail = entry.group('tail');
    if (tail !== '' && !isDigits(tail)) return invalid('The trailing group must be digits.');
    return tail.length > 1 ? invalid('The trailing group is one digit.') : valid;
  }
}

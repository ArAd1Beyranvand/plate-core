import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

const serialChars = '0123456789ABCDEFGHJKLMNPQRSTUVWXYZ';
const cityChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
const suffixes = '学警挂港澳试超';
const energyLetters = 'ABCDEFGHJK';

const isSerialChars = (s: string): boolean => s !== '' && [...s].every((c) => serialChars.includes(c));

const letterCount = (s: string): number => [...s].filter((c) => cityChars.includes(c)).length;

/**
 * Judges a `ChinaPlates.standard` value. Reports, never bars a keystroke.
 *
 * Checks: a city letter from A-Z without I and O; a five-character serial
 * of digits and letters (no I, O) with at most two letters, whose last place
 * may instead be a suffix Hanzi (学 警 挂 港 澳 试 超). The province needs no
 * check: its alphabet is a picker.
 */
export class ChinaValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonCity = 'The city letter is A–Z without I and O.';
  static readonly reasonSerial =
    'The serial is five digits or letters (no I, O), at most two of them letters; the last place may be 学 警 挂 港 澳 试 超.';

  judge(entry: PlateEntry): PlateValidation {
    return ChinaValidator.validateFields({ city: entry.group('city'), serial: entry.group('serial') });
  }

  static validateFields({ city, serial }: { city: string; serial: string }): PlateValidation {
    if (city.length !== 1 || !cityChars.includes(city)) return invalid(ChinaValidator.reasonCity);
    if (serial.length !== 5) return invalid(ChinaValidator.reasonSerial);
    const body = suffixes.includes(serial[4]) ? serial.substring(0, 4) : serial;
    if (!isSerialChars(body) || letterCount(body) > 2) return invalid(ChinaValidator.reasonSerial);
    return valid;
  }
}

/**
 * Judges a New Energy value on `ChinaPlates.newEnergySmall` or
 * `newEnergyLarge`: six serial characters, the energy letter (A–E G–K; D
 * electric, F other fuels) first on a small plate and last on a large one.
 */
export class ChinaNewEnergyValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  /** Whether the energy letter ends the serial (a large vehicle). */
  readonly large: boolean;

  constructor({ large = false }: { large?: boolean } = {}) {
    super();
    this.large = large;
  }

  static readonly reasonSerial = 'The serial is six digits or letters (no I, O).';
  static readonly reasonEnergy = 'The energy letter is A–E or F–K (D electric, F other fuels).';

  judge(entry: PlateEntry): PlateValidation {
    const serial = entry.group('serial');
    if (serial.length !== 6 || !isSerialChars(serial)) return invalid(ChinaNewEnergyValidator.reasonSerial);
    return energyLetters.includes(this.large ? serial[5] : serial[0]) ? valid : invalid(ChinaNewEnergyValidator.reasonEnergy);
  }
}

/**
 * Judges a `ChinaPlates.diplomatic` value: three digits of mission and three
 * of serial. The article lists no code range; Israel's 157 is refused by
 * the spec's restriction before this runs.
 */
export class ChinaDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonDigits = 'A diplomatic plate is a three-digit mission code and a three-digit serial.';

  judge(entry: PlateEntry): PlateValidation {
    return isDigitsOfLength(entry.group('mission'), 3) && isDigitsOfLength(entry.group('serial'), 3) ? valid : invalid(ChinaDiplomaticValidator.reasonDigits);
  }
}

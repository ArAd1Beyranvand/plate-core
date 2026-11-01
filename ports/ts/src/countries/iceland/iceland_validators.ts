import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** The countries a diplomatic plate's mission letter stands for. */
export const IcelandMissions = {
  names: {
    A: 'United States',
    B: 'United Kingdom',
    C: 'Denmark',
    D: 'Finland',
    E: 'France',
    F: 'India',
    G: 'China',
    H: 'Norway',
    I: 'Poland',
    J: 'Russia',
    K: 'Sweden',
    L: 'Czech Republic',
    M: 'Canada',
    N: 'Germany',
    O: 'International Monetary Fund',
    P: 'Japan',
    R: 'European Union',
    S: 'North Atlantic Treaty Organisation',
    T: 'Spain',
  } as Readonly<Record<string, string>>,
};

const letters = /^[A-Z]{2}$/;
const threeDigits = /^[0-9]{3}$/;
const letterTwoDigits = /^[A-Z][0-9]{2}$/;

/** Judges an Icelandic plate: two letters, then three digits or a letter and two digits. Reports, never bars a keystroke. */
export class IcelandValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The prefix is two letters.';
  static readonly reasonSerial = 'The second field is three digits or a letter and two digits.';
  static readonly reasonMission = 'A diplomatic plate is CD, a mission letter and two digits.';
  static readonly reasonDealer = 'A dealer plate is RN and three digits.';

  judge(entry: PlateEntry): PlateValidation {
    const prefix = entry.group('letters');
    const serial = entry.group('serial');
    if (!letters.test(prefix)) return invalid(IcelandValidator.reasonLetters);
    if (prefix === 'CD') {
      if (!letterTwoDigits.test(serial) || !Object.hasOwn(IcelandMissions.names, serial[0])) return invalid(IcelandValidator.reasonMission);
    } else if (prefix === 'RN') {
      if (!threeDigits.test(serial)) return invalid(IcelandValidator.reasonDealer);
    } else if (!threeDigits.test(serial) && !letterTwoDigits.test(serial)) {
      return invalid(IcelandValidator.reasonSerial);
    }
    return valid;
  }
}

/** Judges a vanity plate: two to six characters that do not fit the standard format. */
export class IcelandVanityValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLength = 'A vanity plate is two to six characters.';
  static readonly reasonStandard = 'A vanity plate must not follow the standard format.';

  judge(entry: PlateEntry): PlateValidation {
    const value = entry.group('serial');
    if (value.length < 2 || value.length > 6) return invalid(IcelandVanityValidator.reasonLength);
    return /^[A-Z]{2}([0-9]{3}|[A-Z][0-9]{2})$/.test(value) ? invalid(IcelandVanityValidator.reasonStandard) : valid;
  }
}

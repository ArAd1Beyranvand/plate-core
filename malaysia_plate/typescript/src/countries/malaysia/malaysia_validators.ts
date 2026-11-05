import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from 'plate_core/core/validators/plate_validator';

const notIssued = /[IO]/;

/**
 * Advisory validator for `MalaysiaPlates.singleRow`, `twoRow` and `ev`.
 *
 * I and O are never issued; the number runs 1-9999 with no leading zero; a
 * Sabah (`S...`) suffix is never Q or S. The military `Z` is accepted. State
 * letters and vanity series (which break every rule here) are not checked.
 */
export class MalaysiaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonPrefixMissing = 'A plate starts with letters.';
  static readonly reasonNoIO = 'I and O are not issued on Malaysian plates.';
  static readonly reasonNumber = 'The number is 1 to 9999.';
  static readonly reasonLeadingZero = 'The number has no leading zero.';
  static readonly reasonSabahSuffix = 'A Sabah suffix is never Q or S.';

  judge(entry: PlateEntry): PlateValidation {
    return MalaysiaValidator.validateFields({ prefix: entry.group('prefix'), number: entry.group('number'), suffix: entry.group('suffix') });
  }

  static validateFields(o: { prefix: string; number: string; suffix?: string }): PlateValidation {
    const { prefix, number, suffix = '' } = o;
    const V = MalaysiaValidator;
    if (prefix === '') return invalid(V.reasonPrefixMissing);
    if (notIssued.test(prefix + suffix)) return invalid(V.reasonNoIO);
    if (number === '' || number.length > 4 || !isDigits(number)) return invalid(V.reasonNumber);
    if (number.startsWith('0')) return invalid(V.reasonLeadingZero);
    if (prefix.startsWith('S') && (suffix === 'Q' || suffix === 'S')) return invalid(V.reasonSabahSuffix);
    return valid;
  }
}

/**
 * Advisory validator for `MalaysiaPlates.diplomatic`: two two-digit numbers
 * and a mission code. No number ranges are documented.
 */
export class MalaysiaDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'mission';

  static readonly reasonDigits = 'Both numbers are two digits.';
  static readonly reasonMission = 'The code is DC, CC, UN or PA.';

  private static readonly missions: ReadonlySet<string> = new Set(['DC', 'CC', 'UN', 'PA']);

  judge(entry: PlateEntry): PlateValidation {
    const country = entry.group('country');
    const serial = entry.group('serial');
    if (country.length !== 2 || serial.length !== 2 || !isDigits(country) || !isDigits(serial)) {
      return invalid(MalaysiaDiplomaticValidator.reasonDigits);
    }
    if (!MalaysiaDiplomaticValidator.missions.has(entry.group('mission'))) return invalid(MalaysiaDiplomaticValidator.reasonMission);
    return valid;
  }
}

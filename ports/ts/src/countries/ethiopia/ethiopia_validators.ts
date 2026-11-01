import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

const letters = (s: string, n: number): boolean => new RegExp(`^[A-Z]{${n}}$`).test(s);
const codePoints = (s: string): number => [...s].length;

/** Judges the 2026 private plate: six digits. Reports, never bars a keystroke. */
export class EthiopiaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonNumber = 'The number is six digits.';

  judge(entry: PlateEntry): PlateValidation {
    return isDigitsOfLength(entry.group('number'), 6) ? valid : invalid(EthiopiaValidator.reasonNumber);
  }
}

/** Judges the regional plate: a one-digit class, two Ge'ez letters, six digits and the two-letter Latin region code. */
export class EthiopiaRegionalValidator extends GatedPlateValidator {
  readonly gateGroup = 'code';

  static readonly reasonClass = 'The class is one digit.';
  static readonly reasonGeez = "The region is two Ge'ez letters.";
  static readonly reasonNumber = 'The number is six digits.';
  static readonly reasonCode = 'The region code is two letters.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('class'), 1)) return invalid(EthiopiaRegionalValidator.reasonClass);
    if (codePoints(entry.group('geez')) !== 2) return invalid(EthiopiaRegionalValidator.reasonGeez);
    if (!isDigitsOfLength(entry.group('number'), 6)) return invalid(EthiopiaRegionalValidator.reasonNumber);
    if (!letters(entry.group('code'), 2)) return invalid(EthiopiaRegionalValidator.reasonCode);
    return valid;
  }
}

/**
 * Judges the diplomatic plate: a two-digit mission code, two Ge'ez letters,
 * four digits and the two-letter type. Refuses code `84` on its own account,
 * so it holds even against a spec built without the mission restriction.
 */
export class EthiopiaDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'type';

  static readonly reasonMission = 'The mission code is two digits.';
  static readonly reasonGeez = "The series is two Ge'ez letters.";
  static readonly reasonNumber = 'The number is four digits.';
  static readonly reasonType = 'The type is two letters.';
  static readonly refusedMissions: readonly string[] = ['84'];
  static readonly notFound = 'COUNTRY NOT FOUND';

  override validate(entry: PlateEntry): PlateValidation {
    if (EthiopiaDiplomaticValidator.refusedMissions.includes(entry.group('mission'))) return invalid(EthiopiaDiplomaticValidator.notFound);
    return super.validate(entry);
  }

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('mission'), 2)) return invalid(EthiopiaDiplomaticValidator.reasonMission);
    if (codePoints(entry.group('series')) !== 2) return invalid(EthiopiaDiplomaticValidator.reasonGeez);
    if (!isDigitsOfLength(entry.group('number'), 4)) return invalid(EthiopiaDiplomaticValidator.reasonNumber);
    if (!letters(entry.group('type'), 2)) return invalid(EthiopiaDiplomaticValidator.reasonType);
    return valid;
  }
}

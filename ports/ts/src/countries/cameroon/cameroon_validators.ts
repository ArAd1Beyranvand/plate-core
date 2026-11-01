import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/**
 * Judges a regular plate (`LT 128 AB`): region code, three or four digits,
 * one- or two-letter series. Reports, never bars a keystroke.
 */
export class CameroonValidator extends GatedPlateValidator {
  static readonly regions: ReadonlySet<string> = new Set(['AD', 'CE', 'EN', 'ES', 'LT', 'NO', 'NW', 'OU', 'SU', 'SW']);

  readonly gateGroup = 'number';

  static readonly reasonRegion = 'The region is one of the ten region codes.';
  static readonly reasonNumber = 'The number is three or four digits.';
  static readonly reasonSeries = 'The series is one or two letters.';

  judge(entry: PlateEntry): PlateValidation {
    if (!CameroonValidator.regions.has(entry.group('region'))) return invalid(CameroonValidator.reasonRegion);
    const number = entry.group('number');
    if (!isDigitsOfLength(number, 3) && !isDigitsOfLength(number, 4)) return invalid(CameroonValidator.reasonNumber);
    if (!/^[A-Z]{1,2}$/.test(entry.group('series'))) return invalid(CameroonValidator.reasonSeries);
    return valid;
  }
}

/**
 * Judges a diplomatic plate (`CMD 38 2`): `CM`, `D`, a two-digit mission code
 * and a one-digit suffix. Only digit counts are checked; how codes split
 * across the cells is undocumented.
 */
export class CameroonDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonPrefix = 'The prefix is CMD.';
  static readonly reasonNumber = 'The mission code is two digits.';
  static readonly reasonSuffix = 'The suffix is one digit.';

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('mission') !== 'CM' || entry.group('type') !== 'D') return invalid(CameroonDiplomaticValidator.reasonPrefix);
    if (!isDigitsOfLength(entry.group('number'), 2)) return invalid(CameroonDiplomaticValidator.reasonNumber);
    if (!isDigitsOfLength(entry.group('suffix'), 1)) return invalid(CameroonDiplomaticValidator.reasonSuffix);
    return valid;
  }
}

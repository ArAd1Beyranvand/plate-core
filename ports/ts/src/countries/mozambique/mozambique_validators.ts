import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

const provinceCodes: ReadonlySet<string> = new Set(['CA', 'GZ', 'IB', 'MC', 'MP', 'MN', 'NP', 'NS', 'SF', 'TT', 'ZB']);

/**
 * Judges a 2011-series plate (`ABC 123 MC`): three letters, three digits and
 * a province code. Reports, never bars a keystroke.
 */
export class MozambiqueValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonLetters = 'The series is three letters.';
  static readonly reasonNumber = 'The number is three digits.';
  static readonly reasonProvince = 'The province is CA, GZ, IB, MC, MP, MN, NP, NS, SF, TT or ZB.';

  judge(entry: PlateEntry): PlateValidation {
    const V = MozambiqueValidator;
    if (!/^[A-Z]{3}$/.test(entry.group('letters'))) return invalid(V.reasonLetters);
    if (!isDigitsOfLength(entry.group('number'), 3)) return invalid(V.reasonNumber);
    if (!provinceCodes.has(entry.group('province'))) return invalid(V.reasonProvince);
    return valid;
  }
}

/**
 * Judges a pre-2011 plate (`MLY 01-81`): an `M`, two district letters and two
 * pairs of digits.
 */
export class MozambiqueLegacyValidator extends GatedPlateValidator {
  readonly gateGroup = 'first';

  static readonly reasonLetters = 'The series is M and two district letters.';
  static readonly reasonDigits = 'The number is two pairs of digits.';

  judge(entry: PlateEntry): PlateValidation {
    const V = MozambiqueLegacyValidator;
    if (!/^M[A-Z]{2}$/.test(entry.group('letters'))) return invalid(V.reasonLetters);
    if (!isDigitsOfLength(entry.group('first'), 2) || !isDigitsOfLength(entry.group('second'), 2)) return invalid(V.reasonDigits);
    return valid;
  }
}

import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

const letterPair = /^[A-HJ-NP-TV-Z]{2}$/;

/** Judges an Italian plate: two letters, three digits and two letters, or two letters and five digits on a motorcycle. Reports, never bars a keystroke. */
export class ItalyValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonPrefix = 'The prefix is two letters (no I, O, Q, U).';
  static readonly reasonNumber = 'The number is three digits, or five on a motorcycle.';
  static readonly reasonSuffix = 'The suffix is two letters (no I, O, Q, U).';

  judge(entry: PlateEntry): PlateValidation {
    if (!letterPair.test(entry.group('prefix'))) return invalid(ItalyValidator.reasonPrefix);
    const suffix = entry.group('suffix');
    if (!isDigitsOfLength(entry.group('number'), suffix === '' ? 5 : 3)) return invalid(ItalyValidator.reasonNumber);
    return suffix !== '' && !letterPair.test(suffix) ? invalid(ItalyValidator.reasonSuffix) : valid;
  }
}

/** Judges a diplomatic or consular plate: a number of `digits` digits and a two-letter country code. */
export class ItalyDiplomaticValidator extends GatedPlateValidator {
  readonly digits: number;
  readonly consular: boolean;

  constructor({ digits = 4, consular = false }: { readonly digits?: number; readonly consular?: boolean } = {}) {
    super();
    this.digits = digits;
    this.consular = consular;
  }

  readonly gateGroup = 'number';

  static readonly reasonNumber = 'The number is three or four digits.';
  static readonly reasonCode = 'The country code is two letters.';
  static readonly reasonConsular = 'Consular codes leave out Q and V.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('number'), this.digits)) return invalid(ItalyDiplomaticValidator.reasonNumber);
    const code = entry.group('code');
    if (!/^[A-Z]{2}$/.test(code)) return invalid(ItalyDiplomaticValidator.reasonCode);
    return this.consular && (code.includes('Q') || code.includes('V')) ? invalid(ItalyDiplomaticValidator.reasonConsular) : valid;
  }
}

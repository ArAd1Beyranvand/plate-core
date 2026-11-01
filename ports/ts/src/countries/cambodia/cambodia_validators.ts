import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Issued class digits: motorcycle 1, private car 2, large private car 3, agricultural 4, engineering 5, truck trailer 7, special 9. */
export const cambodiaClassDigits: ReadonlySet<string> = new Set(['1', '2', '3', '4', '5', '7', '9']);

/**
 * Judges a captioned or long plate: class digit, one or two letters when the
 * plate has them, four digits. Reports, never bars a keystroke.
 */
export class CambodiaValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonClass = "The first number is not one of the article's vehicle classes.";
  static readonly reasonLetters = 'The register is one or two letters.';
  static readonly reasonSerial = 'The number is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!cambodiaClassDigits.has(entry.group('class'))) return invalid(CambodiaValidator.reasonClass);
    if (entry.spec.indicesOfGroup('letters').length > 0) {
      const letters = Array.from(entry.group('letters')).length;
      if (letters < 1 || letters > 2) return invalid(CambodiaValidator.reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('serial'), 4)) return invalid(CambodiaValidator.reasonSerial);
    return valid;
  }
}

/**
 * Judges a stacked plate by the registers its spec has: `CD` + two-digit
 * mission; `ONG` + three-digit organisation and class digit; or a two-digit
 * code on the motorcycle plate; each with a three-digit serial.
 */
export class CambodiaStackedValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonPrefix = 'The prefix is CD or ONG.';
  static readonly reasonCode = 'The code is two or three digits.';
  static readonly reasonSerial = 'The number is three digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (entry.spec.indicesOfGroup('prefix').length > 0 && !['CD', 'ONG'].includes(entry.group('prefix'))) return invalid(CambodiaStackedValidator.reasonPrefix);
    for (const key of ['mission', 'org', 'code']) {
      if (entry.spec.indicesOfGroup(key).length > 0 && !isDigitsOfLength(entry.group(key), key === 'org' ? 3 : 2)) return invalid(CambodiaStackedValidator.reasonCode);
    }
    if (!isDigitsOfLength(entry.group('serial'), 3)) return invalid(CambodiaStackedValidator.reasonSerial);
    return valid;
  }
}

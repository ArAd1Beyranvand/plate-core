import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/**
 * Judges a Mayotte SIV plate: two letters, three digits (001–999) and
 * two letters, with the département `976` on the right. The letters leave
 * out I, O and U, and the SS pair. Reports, never bars a keystroke.
 */
export class MayotteValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonPrefix = 'The prefix is two letters (no I, O, U or SS).';
  static readonly reasonNumber = 'The number is three digits, 001–999.';
  static readonly reasonSuffix = 'The suffix is two letters (no I, O, U or SS).';
  static readonly reasonDepartment = 'The département code is 976.';

  static readonly department = '976';

  private static readonly letters = /^[A-HJ-NP-TV-Z]{2}$/;

  judge(entry: PlateEntry): PlateValidation {
    const prefix = entry.group('prefix');
    if (!MayotteValidator.letters.test(prefix) || prefix === 'SS') return invalid(MayotteValidator.reasonPrefix);
    const number = entry.group('number');
    if (!isDigitsOfLength(number, 3) || number === '000') return invalid(MayotteValidator.reasonNumber);
    const suffix = entry.group('suffix');
    if (!MayotteValidator.letters.test(suffix) || suffix === 'SS') return invalid(MayotteValidator.reasonSuffix);
    const code = entry.group('department');
    if (code !== '' && code !== MayotteValidator.department) return invalid(MayotteValidator.reasonDepartment);
    return valid;
  }
}

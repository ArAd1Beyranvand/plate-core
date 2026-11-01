import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/**
 * Judges a Finnish plate, field by field. Reports, never bars a keystroke.
 *
 * Regular and motorcycle plates are two or three letters and one to three
 * digits not starting with 0 (`ABC-123`); the rule barring a leading P, W or
 * D is not enforced, because vanity plates may break it. Åland plates start
 * `ÅL` and take up to five digits. Export plates are one letter and up to
 * four digits. Diplomatic plates are `CD` with up to four digits or `C` with
 * up to five.
 */
export class FinlandValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonLetters = 'The letters are two or three of A–Z, Å, Ä, Ö.';
  static readonly reasonNumber = 'The number is one to three digits, not starting with 0.';
  static readonly reasonAland = 'The Åland number is up to five digits.';
  static readonly reasonExport = 'The export number is up to four digits.';
  static readonly reasonCode = 'The prefix is C or CD.';
  static readonly reasonDiplomatic = 'CD takes up to four digits, C up to five.';

  judge(entry: PlateEntry): PlateValidation {
    const number = entry.group('number');
    const code = entry.group('code');
    const upTo = (max: number) => isDigits(number) && number.length <= max;
    if (code !== '') {
      if (code !== 'C' && code !== 'CD') return invalid(FinlandValidator.reasonCode);
      return upTo(code === 'C' ? 5 : 4) ? valid : invalid(FinlandValidator.reasonDiplomatic);
    }
    const letters = entry.group('letters');
    if (!/^[A-ZÅÄÖ]+$/.test(letters)) return invalid(FinlandValidator.reasonLetters);
    if (letters.length === 1) return upTo(4) ? valid : invalid(FinlandValidator.reasonExport);
    if (letters.length > 3) return invalid(FinlandValidator.reasonLetters);
    if (letters.startsWith('ÅL')) return upTo(5) ? valid : invalid(FinlandValidator.reasonAland);
    return upTo(3) && !number.startsWith('0') ? valid : invalid(FinlandValidator.reasonNumber);
  }
}

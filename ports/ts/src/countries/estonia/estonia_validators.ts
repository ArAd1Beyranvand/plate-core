import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/**
 * Judges an Estonian plate, field by field. Reports, never bars a keystroke.
 *
 * Regular plates are three digits and three letters. Diplomatic plates are
 * `CD` or `AT` with three or four digits, or `CMD` (heads of mission) with
 * two or three. Defence Forces plates are three digits then `K` and a letter,
 * or `EK` and a letter.
 */
export class EstoniaValidator implements PlateValidator {
  static readonly reasonRegular = 'Three digits then three letters.';
  static readonly reasonCode = 'The prefix is CD, AT or CMD.';
  static readonly reasonDiplomatic = 'CD and AT take three or four digits, CMD two or three.';
  static readonly reasonDefence = 'Three digits, then K and a letter or EK and a letter.';

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const number = entry.group('number');
    const letters = entry.group('letters');
    const code = entry.group('code');
    if (code !== '') return this.diplomatic(code, number);
    if (number === '' || letters === '') return valid;
    if (entry.spec.id === 'ee.defence') {
      const shape = (letters.length === 2 && letters.startsWith('K')) || (letters.length === 3 && letters.startsWith('EK'));
      return isDigitsOfLength(number, 3) && shape ? valid : invalid(EstoniaValidator.reasonDefence);
    }
    return isDigitsOfLength(number, 3) && letters.length === 3 ? valid : invalid(EstoniaValidator.reasonRegular);
  }

  private diplomatic(code: string, number: string): PlateValidation {
    const min = code === 'CD' || code === 'AT' ? 3 : code === 'CMD' ? 2 : null;
    if (min === null) return code.length < 2 ? valid : invalid(EstoniaValidator.reasonCode);
    if (number === '') return valid;
    return isDigits(number) && number.length >= min && number.length <= min + 1 ? valid : invalid(EstoniaValidator.reasonDiplomatic);
  }
}

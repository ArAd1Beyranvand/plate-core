import { PlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** Judges a Latvian plate, field by field. Reports, never bars a keystroke.
 *
 * Ordinary, taxi and electric plates are two letters and one to four digits;
 * diplomatic plates are
 * `CD` (or `C`) and four digits whose first two name the mission. */
export class LatviaValidator implements PlateValidator {
  static readonly reasonRegular = 'Two letters, then one to four digits.';
  static readonly reasonDiplomatic = 'CD, then four digits.';

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused != null) return refused;
    const letters = entry.group('letters');
    const number = entry.group('number');
    if (letters.length === 0 || number.length === 0) return valid;
    const id = entry.spec.id;
    if (id === 'lv.diplomatic') {
      return (letters === 'CD' || letters === 'C') && isDigitsOfLength(number, 4)
        ? valid
        : invalid(LatviaValidator.reasonDiplomatic);
    }
    if (letters.length !== 2 || !isDigits(number)) {
      return invalid(LatviaValidator.reasonRegular);
    }
    return valid;
  }
}

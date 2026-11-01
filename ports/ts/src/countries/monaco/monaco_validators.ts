import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid, isLetters } from '../../core/validators/plate_validator';

const serialRe = /^(?:[A-Z][0-9]{3}|[0-9]{4}|[0-9]{3}[A-Z])$/;
const digitsRe = /^[0-9]{2}$/;

/**
 * Judges a Monaco plate. A car's `serial` is one letter and three digits, four
 * digits, or three digits and one letter; a motorcycle's is two `letters` and
 * two `digits`. Reports, never bars a keystroke.
 */
export class MonacoValidator implements PlateValidator {
  static readonly reasonSerial = 'The serial is four digits, a letter and three digits, or three digits and a letter.';
  static readonly reasonLetters = 'The motorcycle prefix is two letters.';
  static readonly reasonDigits = 'The motorcycle number is two digits.';

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const serial = entry.group('serial');
    if (serial !== '') return serialRe.test(serial) ? valid : invalid(MonacoValidator.reasonSerial);
    const digits = entry.group('digits');
    if (digits === '') return valid;
    if (!isLetters(entry.group('letters'), 2)) return invalid(MonacoValidator.reasonLetters);
    return digitsRe.test(digits) ? valid : invalid(MonacoValidator.reasonDigits);
  }
}

import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

const lettersRe = /^[A-Z]{2}$/;
const letterRe = /^[A-Z]$/;
const mixedRe = /^[A-Z][0-9]$/;
const isPair = (v: string): boolean => lettersRe.test(v) || isDigitsOfLength(v, 2);

/**
 * Judges a Portuguese plate by the groups its spec carries.
 *
 * A registration is three fields of two characters, in one of the series'
 * orders: `AA 00 AA` (2020), `00 AA 00` (2005), `00 00 AA` (1992) and
 * `AA 00 00` (1937), or `A1 00 AA` on the US Forces plates. The ribbon's
 * `year` and `month` are two digits each, the month 01–12. A GNR plate is
 * `GNR`, one letter and four digits; a trailer plate one or two district
 * letters and one to six digits; a diplomatic plate one to three embassy
 * digits, `CD` and three digits. Reports, never bars a keystroke.
 */
export class PortugalValidator implements PlateValidator {
  static readonly reasonShape = 'A plate is three fields of two characters: letters AA, digits 00.';
  static readonly reasonDate = 'The ribbon is a two-digit year and month.';
  static readonly reasonGnr = 'A GNR plate is one letter and four digits.';
  static readonly reasonTrailer = 'A trailer plate is one or two district letters and up to six digits.';
  static readonly reasonDiplomatic = 'A diplomatic plate is one to three digits, CD and three digits.';

  validate(entry: PlateEntry): PlateValidation {
    const V = PortugalValidator;
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const embassy = entry.group('embassy');
    if (embassy !== '') {
      return embassy.length <= 3 && isDigits(embassy) && entry.group('code') === 'CD' && isDigitsOfLength(entry.group('number'), 3) ? valid : invalid(V.reasonDiplomatic);
    }
    const district = entry.group('district');
    if (district !== '') {
      const number = entry.group('number');
      return lettersRe.test(district.padEnd(2, 'A')) && isDigits(number) && number.length <= 6 ? valid : invalid(V.reasonTrailer);
    }
    const letter = entry.group('letter');
    if (letter !== '') return letterRe.test(letter) && isDigitsOfLength(entry.group('number'), 4) ? valid : invalid(V.reasonGnr);
    const first = entry.group('first');
    if (first === '') return valid;
    if (!(isPair(first) || mixedRe.test(first)) || !isPair(entry.group('second')) || !isPair(entry.group('third'))) return invalid(V.reasonShape);
    const year = entry.group('year');
    const month = entry.group('month');
    if (year !== '' || month !== '') {
      const m = isDigits(month) ? Number(month) : null;
      if (!isDigitsOfLength(year, 2) || !isDigitsOfLength(month, 2) || m === null || m < 1 || m > 12) return invalid(V.reasonDate);
    }
    return valid;
  }
}

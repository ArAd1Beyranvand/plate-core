import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

const consonants = /^[BCDFGHJKLPRSTVWXYZ]+$/;
const letters = /^[A-Z]+$/;
const digits = /^[0-9]+$/;
const diplomaticPrefixes = ['CD', 'CC', 'AT', 'CH', 'OI', 'PAT'];

/**
 * Judges a Chilean plate by which groups it has:
 *
 * - `first`, `second`, `number`: four consonants and two digits (`BB·BB·10`),
 *   or on a trailer two letters and two pairs of digits (`JD·20·67`).
 * - `first`, `mission`, `number`: diplomatic, two prefix letters and four
 *   digits; the mission pair 39 is refused by `ChileMissions.restriction`.
 * - `first` of three letters and `number` of three digits: a light trailer.
 * - `first` and `number` otherwise: `PR` and three or four digits is
 *   provisional, any other letters and four digits are a police plate.
 *
 * The letters of the 2007 format leave out the vowels, M, N, Ñ and Q.
 * Reports, never bars a keystroke.
 */
export class ChileValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonLetters = 'The letters are consonants (no M, N, Ñ or Q).';
  static readonly reasonNumber = 'The number is two digits.';
  static readonly reasonDiplomatic = 'A diplomatic plate starts CD, CC, AT, CH, OI or PAT.';
  static readonly reasonTrailer = 'A trailer plate is two letters and two pairs of digits.';
  static readonly reasonLight = 'A light trailer is three consonants and three digits.';
  static readonly reasonProvisional = 'A provisional plate is PR and three or four digits.';
  static readonly reasonPolice = 'A police plate is letters and four digits.';

  judge(entry: PlateEntry): PlateValidation {
    const first = entry.group('first');
    const second = entry.group('second');
    const mission = entry.group('mission');
    const number = entry.group('number');

    if (mission !== '') {
      if (!diplomaticPrefixes.includes(first)) return invalid(ChileValidator.reasonDiplomatic);
      if (!isDigitsOfLength(mission, 2) || !isDigitsOfLength(number, 2)) return invalid(ChileValidator.reasonNumber);
      return valid;
    }
    if (second !== '') {
      if (digits.test(second)) {
        if (!letters.test(first) || !isDigitsOfLength(second, 2) || !isDigitsOfLength(number, 2)) return invalid(ChileValidator.reasonTrailer);
        return valid;
      }
      if (!consonants.test(first) || !consonants.test(second)) return invalid(ChileValidator.reasonLetters);
      return isDigitsOfLength(number, 2) ? valid : invalid(ChileValidator.reasonNumber);
    }
    if (first.length === 3) {
      return consonants.test(first) && isDigitsOfLength(number, 3) ? valid : invalid(ChileValidator.reasonLight);
    }
    if (first === 'PR') {
      return isDigitsOfLength(number, 3) || isDigitsOfLength(number, 4) ? valid : invalid(ChileValidator.reasonProvisional);
    }
    return letters.test(first) && isDigitsOfLength(number, 4) ? valid : invalid(ChileValidator.reasonPolice);
  }
}

import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Norwegian plate. A regular plate is two letters and four or five
 * digits (`AB 12345`); a diplomatic plate is `CD`, a two-digit mission code
 * and a three-digit sequence. Reports, never bars a keystroke; the one
 * refusal is the restriction the diplomatic spec carries. */
export class NorwayValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonLetters = 'The prefix is two letters (no G, I, M, O, Q).';
  static readonly reasonNumber = 'The number is four or five digits.';
  static readonly reasonCode = 'The prefix is CD.';
  static readonly reasonEmbassy = 'The mission code is two digits.';
  static readonly reasonCar = 'The sequence is three digits.';
  static readonly _prefix = new RegExp('^[ABCDEFHJKLNPRSTUVWXYZ]{2}$');

  judge(entry: PlateEntry): PlateValidation {
    const code = entry.group('code');
    if (code !== undefined && code !== '') {
      if (code !== 'CD') {
        return invalid(NorwayValidator.reasonCode);
      }
      if (!isDigitsOfLength(entry.group('embassy'), 2)) {
        return invalid(NorwayValidator.reasonEmbassy);
      }
      if (!isDigitsOfLength(entry.group('number'), 3)) {
        return invalid(NorwayValidator.reasonCar);
      }
      return valid;
    }
    if (!NorwayValidator._prefix.test(entry.group('letters')!)) {
      return invalid(NorwayValidator.reasonLetters);
    }
    const number = entry.group('number')!;
    if (!isDigits(number) || number.length < 4 || number.length > 5) {
      return invalid(NorwayValidator.reasonNumber);
    }
    return valid;
  }
}

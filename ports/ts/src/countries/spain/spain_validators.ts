import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Spanish plate. A registration is four digits and three consonants
 * (`1234 BCD`); a diplomatic plate is a prefix of CD, CC, TA or OI, one to
 * three digits for the embassy or organisation, and three digits. Reports,
 * never bars a keystroke; the one refusal is the restriction the diplomatic
 * specs carry. */
export class SpainValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonNumber = 'The number is four digits.';
  static readonly reasonLetters = 'The counter is three consonants (no vowels, no Q).';
  static readonly reasonCode = 'The prefix is CD, CC, TA or OI.';
  static readonly reasonEmbassy = 'The embassy code is one to three digits.';
  static readonly reasonCar = 'The car number is three digits.';

  private static readonly _diplomaticCodes = ['CD', 'CC', 'TA', 'OI'];
  private static readonly _counter = /^[BCDFGHJKLMNPRSTVWXYZ]{3}$/;

  judge(entry: PlateEntry): PlateValidation {
    const code = entry.group('code');
    if (code !== '') {
      if (!SpainValidator._diplomaticCodes.includes(code)) {
        return invalid(SpainValidator.reasonCode);
      }
      const embassy = entry.group('embassy');
      if (!isDigits(embassy) || embassy.length > 3) {
        return invalid(SpainValidator.reasonEmbassy);
      }
      if (!isDigitsOfLength(entry.group('number'), 3)) {
        return invalid(SpainValidator.reasonCar);
      }
      return valid;
    }
    if (!isDigitsOfLength(entry.group('number'), 4)) {
      return invalid(SpainValidator.reasonNumber);
    }
    if (!SpainValidator._counter.test(entry.group('letters'))) {
      return invalid(SpainValidator.reasonLetters);
    }
    return valid;
  }
}

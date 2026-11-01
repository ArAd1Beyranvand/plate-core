import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Melilla plate. A registration is four digits and three consonants
 * (`1234 BCD`); a diplomatic plate is a prefix from CD, CC, TA or OI, one to
 * three digits for the embassy or organisation, and three digits; a police
 * plate is one to three letters and four digits. Reports, never bars a
 * keystroke; the one refusal is the restriction the diplomatic specs carry. */
export class MelillaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonNumber = 'The number is four digits.';
  static readonly reasonLetters = 'The counter is three consonants (no vowels, no Q).';
  static readonly reasonCode = 'The prefix is CD, CC, TA or OI.';
  static readonly reasonEmbassy = 'The embassy code is one to three digits.';
  static readonly reasonCar = 'The car number is three digits.';
  static readonly reasonPrefix = 'The prefix is one to three letters.';

  private static readonly _diplomaticCodes = ['CD', 'CC', 'TA', 'OI'];
  private static readonly _counter = /^[BCDFGHJKLMNPRSTVWXYZ]{3}$/;
  private static readonly _prefix = /^[A-Z]{1,3}$/;

  judge(entry: PlateEntry): PlateValidation {
    const code = entry.group('code');
    if (code !== '') {
      if (!MelillaValidator._diplomaticCodes.includes(code)) {
        return invalid(MelillaValidator.reasonCode);
      }
      const embassy = entry.group('embassy');
      if (!isDigits(embassy) || embassy.length > 3) {
        return invalid(MelillaValidator.reasonEmbassy);
      }
      if (!isDigitsOfLength(entry.group('number'), 3)) {
        return invalid(MelillaValidator.reasonCar);
      }
      return valid;
    }
    if (!isDigitsOfLength(entry.group('number'), 4)) {
      return invalid(MelillaValidator.reasonNumber);
    }
    const prefix = entry.group('prefix');
    if (prefix !== '') {
      return MelillaValidator._prefix.test(prefix) ? valid : invalid(MelillaValidator.reasonPrefix);
    }
    if (!MelillaValidator._counter.test(entry.group('letters'))) {
      return invalid(MelillaValidator.reasonLetters);
    }
    return valid;
  }
}

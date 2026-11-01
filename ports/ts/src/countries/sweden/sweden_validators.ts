import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** A registration is three letters, two digits and a digit or letter; a dealer
 * plate is three letters and three digits; a diplomatic plate is a two-letter
 * mission code, three digits and a status letter A-I; a military plate is
 * four to six digits. Reports, never bars a keystroke; the one refusal is the
 * diplomatic spec's restriction. */
export class SwedenValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonLetters = 'The letters are three, none of I, Q, V, Å, Ä, Ö.';
  static readonly reasonNumber = 'The number is two digits and a digit or a letter (not O).';
  static readonly reasonDigits = 'The number is three digits.';
  static readonly reasonCode = 'The mission code is two letters (no I, O, Q, V).';
  static readonly reasonStatus = 'The status letter is A to I.';
  static readonly reasonMilitary = 'The number is four to six digits.';

  private static readonly _letters = /^[A-HJ-PR-UW-Z]{3}$/;
  private static readonly _last = /^[0-9]{2}[0-9A-HJ-NPR-UW-Z]$/;
  private static readonly _mission = /^[A-HJ-NPR-UW-Z]{2}$/;
  private static readonly _status = /^[A-I]$/;

  judge(entry: PlateEntry): PlateValidation {
    const number = entry.group('number');
    const code = entry.group('code');
    if (code !== '') {
      if (!SwedenValidator._mission.test(code)) {
        return invalid(SwedenValidator.reasonCode);
      }
      if (!isDigitsOfLength(number, 3)) {
        return invalid(SwedenValidator.reasonDigits);
      }
      if (!SwedenValidator._status.test(entry.group('status'))) {
        return invalid(SwedenValidator.reasonStatus);
      }
      return valid;
    }
    const letters = entry.group('letters');
    if (letters === '') {
      if (!isDigits(number) || number.length < 4 || number.length > 6) {
        return invalid(SwedenValidator.reasonMilitary);
      }
      return valid;
    }
    if (!SwedenValidator._letters.test(letters)) {
      return invalid(SwedenValidator.reasonLetters);
    }
    // Dealer plates (three digits) and registrations (two digits and a last
    // character) both pass; the temporary plate's last field is a letter.
    if (!isDigitsOfLength(number, 3) && !SwedenValidator._last.test(number)) {
      return invalid(SwedenValidator.reasonNumber);
    }
    return valid;
  }
}

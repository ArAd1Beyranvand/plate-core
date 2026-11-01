import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges an Andorran plate by its groups. Reports, never bars a keystroke.
 *
 * A standard plate is one letter and four digits (`L 3705`). A temporary plate
 * is `MT`, four digits and an expiry month (a Roman numeral, I to XII) and
 * two-digit year. */
export class AndorraValidator extends GatedPlateValidator {
  readonly gateGroup = 'digits';

  static readonly reasonStandard = 'A plate is one letter and four digits.';
  static readonly reasonTemporary = 'A temporary plate is four digits, a month (I to XII) and a year.';

  private static readonly _month = new RegExp('^(I{1,3}|IV|IX|VI{0,3}|XI{0,2})$', 'u');
  private static readonly _letter = new RegExp('^[A-Z]$', 'u');

  judge(entry: PlateEntry): PlateValidation {
    const digits = entry.group('digits');
    const month = entry.group('month');
    if (month !== undefined && month.length > 0 || entry.group('year') !== undefined && entry.group('year').length > 0) {
      return isDigitsOfLength(digits, 4) &&
        AndorraValidator._month.test(month) &&
        isDigitsOfLength(entry.group('year'), 2)
        ? valid
        : invalid(AndorraValidator.reasonTemporary);
    }
    return isDigitsOfLength(digits, 4) &&
      AndorraValidator._letter.test(entry.group('letter'))
      ? valid
      : invalid(AndorraValidator.reasonStandard);
  }
}

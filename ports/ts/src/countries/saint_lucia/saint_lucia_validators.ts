import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a Saint Lucian plate: a one to three letter prefix (`P`, `PA`, `TX`,
 * `M`, `DM`, `SLG`, `MP`) and one to four digits. Reports, never bars a
 * keystroke; the per-category prefix and digit limits are not enforced. */
export class SaintLuciaValidator extends GatedPlateValidator {
  readonly gateGroup = 'digits';

  static readonly reason = 'A plate is a one to three letter prefix and one to four digits.';

  private static readonly _digits = new RegExp(String.raw`^[0-9]{1,4}$`);
  private static readonly _letters = new RegExp(String.raw`^[A-Z]{1,3}$`);

  judge(entry: PlateEntry): PlateValidation {
    return SaintLuciaValidator._digits.test(entry.group('digits')!) &&
      SaintLuciaValidator._letters.test(entry.group('letters')!)
      ? valid
      : invalid(SaintLuciaValidator.reason);
  }
}

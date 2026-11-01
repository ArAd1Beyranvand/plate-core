import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a plate: the `P` prefix, optionally with a second letter (`P(A)`
since 1997), and one to four digits. Reports, never bars a keystroke. */
export class SaintKittsAndNevisValidator extends GatedPlateValidator {
  readonly gateGroup = 'digits';

  static readonly reason = 'A plate is one or two letters and one to four digits.';

  private static readonly _digits = new RegExp(String.raw`^[0-9]{1,4}$`);
  private static readonly _letters = new RegExp(String.raw`^[A-Z]{1,2}$`);

  judge(entry: PlateEntry): PlateValidation {
    return SaintKittsAndNevisValidator._digits.test(entry.group('digits')) &&
        SaintKittsAndNevisValidator._letters.test(entry.group('letters'))
        ? valid
        : invalid(SaintKittsAndNevisValidator.reason);
  }
}

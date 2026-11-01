import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Barbadian plate: one or two letters (the parish or category code)
 * and one to four digits (`L 4159`, `MA 999`). Reports, never bars a keystroke. */
export class BarbadosValidator extends GatedPlateValidator {
  readonly gateGroup = 'digits';

  static readonly reason = 'A plate is one or two letters and one to four digits.';

  judge(entry: PlateEntry): PlateValidation {
    const digitsMatch = /^[0-9]{1,4}$/.test(entry.group('digits') ?? '');
    const lettersMatch = /^[A-Z]{1,2}$/.test(entry.group('letters') ?? '');
    return digitsMatch && lettersMatch ? valid : invalid(BarbadosValidator.reason);
  }
}

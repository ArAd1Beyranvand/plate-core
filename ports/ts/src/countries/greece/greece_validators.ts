import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/**
 * Judges a registration on any `GreecePlates` spec. Reports, never bars a
 * keystroke.
 *
 * Checks, per field, the lengths the spec's slots declare (letters from the
 * fourteen Greek capitals that have a Latin twin, digits), and that a private
 * car's number runs 1000 to 9999.
 */
export class GreeceValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonLetters = 'The prefix is letters from Α Β Ε Ζ Η Ι Κ Μ Ν Ο Ρ Τ Υ Χ.';
  static readonly reasonDigits = 'The number has the wrong digit count.';
  static readonly reasonRange = 'Private numbers run from 1000 to 9999.';

  judge(entry: PlateEntry): PlateValidation {
    const spec = entry.spec;
    const letters = spec.slots[spec.indicesOfGroup('letters')[0]];
    const number = spec.slots[spec.indicesOfGroup('number')[0]];
    const prefix = entry.group('letters');
    const digits = entry.group('number');
    if (prefix.length < letters.minLength || prefix.length > letters.length || !letters.accepts(prefix)) return invalid(GreeceValidator.reasonLetters);
    if (!isDigits(digits) || digits.length < number.minLength || digits.length > number.length) return invalid(GreeceValidator.reasonDigits);
    if (spec.id === 'gr.private' && Number(digits) < 1000) return invalid(GreeceValidator.reasonRange);
    return valid;
  }
}

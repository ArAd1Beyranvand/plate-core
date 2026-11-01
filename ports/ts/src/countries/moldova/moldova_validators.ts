import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

const month = /^(0[1-9]|1[0-2])$/;
const year = /^[0-9]{2}$/;

const lettersDigits = (letters: number, digits: number): Record<string, RegExp> => ({
  letters: new RegExp(`^[A-Z]{${letters}}$`),
  digits: new RegExp(`^[0-9]{${digits}}$`),
});

const formats: Record<string, Record<string, RegExp>> = {
  'md.private': lettersDigits(3, 3),
  'md.state': lettersDigits(3, 3),
  'md.interior': lettersDigits(3, 4),
  'md.armedForces': lettersDigits(2, 4),
  'md.president': lettersDigits(2, 4),
  'md.protection': lettersDigits(2, 3),
  'md.foreign': { ...lettersDigits(1, 4), month, year },
  'md.exported': { ...lettersDigits(1, 3), suffix: /^[A-Z]$/, month, year },
  'md.resident': lettersDigits(1, 4),
  'md.diplomatic': { ...lettersDigits(2, 3), suffix: /^[A-Z]{2}$/ },
};

/**
 * Judges a Moldovan plate field by field. Reports, never bars a keystroke.
 *
 * Formats are per spec: private and state plates are three letters and
 * three digits, the Ministry of Internal Affairs three and four, the armed
 * forces and president two and four, the protection service two and three,
 * the red plates a letter and four digits (exported: three and a letter)
 * with a month 01–12 and a two-digit year, and the diplomatic plate two
 * letters, three digits and two letters.
 */
export class MoldovaValidator extends GatedPlateValidator {
  readonly gateGroup = 'digits';

  static readonly reason = 'The plate does not match its format.';

  judge(entry: PlateEntry): PlateValidation {
    const format = formats[entry.spec.id];
    if (format === undefined) return valid;
    for (const [key, re] of Object.entries(format)) if (!re.test(entry.group(key))) return invalid(MoldovaValidator.reason);
    return valid;
  }
}

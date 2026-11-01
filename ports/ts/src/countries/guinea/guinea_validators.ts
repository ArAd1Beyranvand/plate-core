import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** Judges a Guinean plate field by field; the groups present on the spec decide which rules apply. Reports, never bars a keystroke. */
export class GuineaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  judge(entry: PlateEntry): PlateValidation {
    const keys = new Set(entry.spec.textGroups.flatMap((g) => (g.key ? [g.key] : [])));
    const legacy = keys.has('prefix');
    const rules: [string, RegExp, string][] = [
      ['series', legacy ? /^[A-Z]{1,2}$/ : /^[A-Z]{2}$/, legacy ? 'The series is 1 or 2 letters.' : 'The series is 2 letters.'],
      ['number', /^\d{4}$/, 'The number is 4 digits.'],
      ['prefix', /^[A-Z]{2}$/, 'The region code is 2 letters (RC is Conakry).'],
      ['region', /^0[1-8]$/, 'The region code is 01 to 08.'],
      ['suffix', /^[A-Z]$/, 'The suffix is 1 letter.'],
    ];
    for (const [key, pattern, reason] of rules) {
      if (keys.has(key) && !pattern.test(entry.group(key))) return invalid(reason);
    }
    return valid;
  }
}

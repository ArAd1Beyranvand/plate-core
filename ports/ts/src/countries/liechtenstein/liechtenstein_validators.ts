import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/**
 * Advisory validator for the number ranges of one category.
 *
 * The serial is digits only; the dealer `U` and customs `Z` are printed by
 * the spec, not typed.
 */
export class LiechtensteinValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';
  /** Inclusive ranges the serial must fall in. */
  readonly ranges: readonly (readonly [number, number])[];
  readonly reason: string;

  constructor(o: { readonly ranges: readonly (readonly [number, number])[]; readonly reason: string }) {
    super();
    this.ranges = o.ranges;
    this.reason = o.reason;
  }

  judge(entry: PlateEntry): PlateValidation {
    const serial = entry.group('serial');
    const n = isDigits(serial) ? Number(serial) : null;
    const ok = n !== null && !serial.startsWith('0') && this.ranges.some(([lo, hi]) => n >= lo && n <= hi);
    const month = entry.group('month');
    const m = /^[0-9]+$/.test(month) ? Number(month) : null;
    const monthOk = month === '' || (m !== null && m >= 1 && m <= 12);
    return ok && monthOk ? valid : invalid(this.reason);
  }
}

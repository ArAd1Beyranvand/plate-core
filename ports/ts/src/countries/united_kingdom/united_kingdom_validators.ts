import { type PlateEntry, type PlateValidation, type PlateValidator, invalid, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** Quiet until something is typed, then every field must reach its minimum
 * length and obey the DVLA letter rules: `area` never uses `I`, `Q` or `Z`
 * (`Z` is only a random letter), `random` never `I` or `Q`. */
export class UnitedKingdomValidator implements PlateValidator {
  private static readonly _forbidden: Readonly<Record<string, string>> = { area: 'IQZ', random: 'IQ' };

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    if (entry.values.every((v) => v === null || v === '')) return valid;
    for (const g of entry.spec.effectiveTextGroups) {
      const key = g.key;
      for (const i of g.indices) {
        const slot = entry.spec.slotAt(i);
        const value = i < entry.values.length ? (entry.values[i] ?? '') : '';
        if (slot !== null && !slot.isComplete(value)) {
          return invalid(`The ${key ?? 'field'} is incomplete.`);
        }
        const bad = (key !== undefined && UnitedKingdomValidator._forbidden[key]) || '';
        if (bad !== '' && value.split('').some((c) => bad.includes(c))) {
          return invalid(`The ${key} never uses ${bad.split('').join(', ')}.`);
        }
      }
    }
    return valid;
  }
}

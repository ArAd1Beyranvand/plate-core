import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, isValid, valid } from '../../core/validators/plate_validator';

const notFound = 'COUNTRY NOT FOUND';
/** The listed diplomatic mission codes (01–86); 09 is refused. */
const missionCodes: ReadonlySet<string> = new Set(
  Array.from({ length: 86 }, (_, i) => String(i + 1).padStart(2, '0')).filter((c) => c !== '09'),
);

/**
 * Every Belarusian number ends in a region digit; the validator stays quiet
 * until it is filled. Advisory, like every validator — except for the spec's
 * restrictions, which [GatedPlateValidator] reports first.
 */
export class BelarusPlateValidator extends GatedPlateValidator {
  readonly gateGroup: string = 'region';

  judge(entry: PlateEntry): PlateValidation {
    for (const g of entry.spec.textGroups) {
      const key = g.key;
      if (key === undefined || key === null) continue;
      if (entry.group(key).length !== g.indices.length) return invalid(`The ${key} is incomplete.`);
    }
    return valid;
  }
}

/**
 * [BelarusPlateValidator] plus the mission register. Refuses `09` on its own
 * account as well, so it holds even against a spec built without the mission restriction.
 */
export class BelarusDiplomaticValidator extends BelarusPlateValidator {
  override validate(entry: PlateEntry): PlateValidation {
    if (entry.group('mission') === '09') return invalid(notFound);
    return super.validate(entry);
  }

  override judge(entry: PlateEntry): PlateValidation {
    const verdict = super.judge(entry);
    if (!isValid(verdict)) return verdict;
    if (!missionCodes.has(entry.group('mission'))) return invalid(notFound);
    return verdict;
  }
}

/** Service plates (`1234 MO`) carry no region digit; gated on the letters. */
export class BelarusServiceValidator extends GatedPlateValidator {
  readonly gateGroup = 'letters';

  judge(entry: PlateEntry): PlateValidation {
    return isDigitsOfLength(entry.group('serial'), 4) ? valid : invalid('The serial is incomplete.');
  }
}

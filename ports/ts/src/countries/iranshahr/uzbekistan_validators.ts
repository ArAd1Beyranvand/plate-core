import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

const refusedMissions: readonly string[] = ['011'];
const notFound = 'COUNTRY NOT FOUND';
const missionCodes: ReadonlySet<string> = new Set(
  '001 002 003 004 005 006 007 008 009 010 020 012 013 014 015 016 017 018 021 022 023 025 026 029 030 031 032 033 035 036 037 038 039 040 041 043 044 046 052'.split(' '),
);

/** Judges an Uzbek plate: every group must be full. Reports, never bars a keystroke. */
export class UzbekistanValidator extends GatedPlateValidator {
  readonly gateGroup = 'region';

  judge(entry: PlateEntry): PlateValidation {
    for (const g of entry.spec.textGroups) {
      if (g.key == null) continue;
      const expected = g.indices.reduce((n, i) => n + entry.spec.slots[i].length, 0);
      if (entry.group(g.key).length !== expected) return invalid(`The ${g.key} is incomplete.`);
    }
    return valid;
  }
}

/** Judges a diplomatic plate: a listed three-digit mission code and a three-digit serial. Refuses code `011` on its own account. */
export class UzbekistanDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'mission';

  override validate(entry: PlateEntry): PlateValidation {
    if (refusedMissions.includes(entry.group('mission'))) return invalid(notFound);
    return super.validate(entry);
  }

  judge(entry: PlateEntry): PlateValidation {
    const mission = entry.group('mission');
    if (mission.length !== 3) return invalid('The mission code is incomplete.');
    if (!missionCodes.has(mission)) return invalid(notFound);
    return entry.group('serial').length === 3 ? valid : invalid('The serial is incomplete.');
  }
}

/** Judges a United Nations plate: a four-digit serial. */
export class UzbekistanUnitedNationsValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  judge(entry: PlateEntry): PlateValidation {
    return isDigitsOfLength(entry.group('serial'), 4) ? valid : invalid('The serial is incomplete.');
  }
}

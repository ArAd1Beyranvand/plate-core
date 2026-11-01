import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** The town codes, from the article's list (which it says may be incomplete). */
export const NamibiaTowns = {
  all: {
    A: 'Arandis', AR: 'Aranos', B: 'Bethanien', BK: 'Bukalo',
    DV: 'Divundu', EN: 'Eenhana', G: 'Grootfontein', GO: 'Gobabis',
    HB: 'Henties Bay', HN: 'Helao Nafidi', K: 'Keetmanshoop',
    KA: 'Karasburg', KH: 'Khorixas', KM: 'Katima Mulilo',
    KR: 'Karibib', KO: 'Okongo', L: 'Lüderitz', M: 'Mariental',
    MA: 'Maltahöhe', MT: 'Omuthiya', ND: 'Ondangwa', NK: 'Nkurenkuru',
    OA: 'Okahao', OH: 'Okahandja', OJ: 'Outjo', OK: 'Okakarara',
    OM: 'Omaruru', ON: 'Otjinene', OP: 'Opuwo', OR: 'Oranjemund',
    OT: 'Otjiwarongo', OV: 'Otavi', R: 'Rehoboth', RC: 'Ruacana',
    RU: 'Rundu', S: 'Swakopmund', SH: 'Oshakati', T: 'Tsumeb',
    TK: 'Tsumkwe', U: 'Usakos', UP: 'Outapi', W: 'Windhoek',
    WB: 'Walvis Bay',
  } as Readonly<Record<string, string>>,
  name: (code: string): string | null => (Object.hasOwn(NamibiaTowns.all, code) ? NamibiaTowns.all[code] : null),
};

function incomplete(entry: PlateEntry): PlateValidation | null {
  for (const g of entry.spec.textGroups) {
    const key = g.key;
    if (key === undefined || key === null) continue;
    const want = g.indices.reduce((n, i) => n + entry.spec.slots[i].length, 0);
    if (entry.group(key).length !== want) return invalid(`The ${key} is incomplete.`);
  }
  return null;
}

/**
 * A standard plate: every slot filled and the town code on the list.
 * Gated on the town code, which is typed last.
 */
export class NamibiaPlateValidator extends GatedPlateValidator {
  readonly gateGroup = 'region';

  judge(entry: PlateEntry): PlateValidation {
    const bad = incomplete(entry);
    if (bad !== null) return bad;
    if (NamibiaTowns.name(entry.group('region')) === null) return invalid('Unknown town code.');
    return valid;
  }
}

/** Personalised, diplomatic and government plates: every slot filled. */
export class NamibiaCompleteValidator implements PlateValidator {
  validate(entry: PlateEntry): PlateValidation {
    return restrictionVerdict(entry) ?? incomplete(entry) ?? valid;
  }
}

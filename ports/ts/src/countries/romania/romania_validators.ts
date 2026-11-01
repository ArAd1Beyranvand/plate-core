import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** The county codes, from the article's table (Bucharest is `B`; `IF` is Ilfov, which surrounds it). */
export const RomaniaCounties = {
  names: {
    B: 'Bucharest', AB: 'Alba', AG: 'Argeș', AR: 'Arad',
    BC: 'Bacău', BH: 'Bihor', BN: 'Bistrița-Năsăud', BR: 'Brăila',
    BT: 'Botoșani', BV: 'Brașov', BZ: 'Buzău', CJ: 'Cluj',
    CL: 'Călărași', CS: 'Caraș-Severin', CT: 'Constanța',
    CV: 'Covasna', DB: 'Dâmbovița', DJ: 'Dolj', GJ: 'Gorj',
    GL: 'Galați', GR: 'Giurgiu', HD: 'Hunedoara', HR: 'Harghita',
    IF: 'Ilfov', IL: 'Ialomița', IS: 'Iași', MH: 'Mehedinți',
    MM: 'Maramureș', MS: 'Mureș', NT: 'Neamț', OT: 'Olt',
    PH: 'Prahova', SB: 'Sibiu', SJ: 'Sălaj', SM: 'Satu Mare',
    SV: 'Suceava', TL: 'Tulcea', TM: 'Timiș', TR: 'Teleorman',
    VL: 'Vâlcea', VN: 'Vrancea', VS: 'Vaslui',
  } as Readonly<Record<string, string>>,
};

const isCounty = (code: string): boolean => Object.hasOwn(RomaniaCounties.names, code);

/**
 * Judges a [RomaniaPlates.standard] value: a county code, two digits (three
 * in Bucharest, never `00`) and three letters without Q or a leading I or O.
 * Advisory: reports, never bars a keystroke.
 */
export class RomaniaValidator extends GatedPlateValidator {
  readonly gateGroup = 'letters';

  static readonly reasonCounty = 'The county code is one of the 42 codes.';
  static readonly reasonNumber = 'The number is two digits, or two or three in Bucharest; not 00.';
  static readonly reasonLetters = 'The letters are three, without Q, and do not begin with I or O.';

  judge(entry: PlateEntry): PlateValidation {
    const V = RomaniaValidator;
    const county = entry.group('county');
    if (!isCounty(county)) return invalid(V.reasonCounty);
    const number = entry.group('number');
    const lengthOk = number.length === 2 || (county === 'B' && number.length === 3);
    if (!lengthOk || !isDigits(number) || Number(number) === 0) return invalid(V.reasonNumber);
    const letters = entry.group('letters');
    if (!/^[A-HJ-NP-Z][A-PR-Z]{2}$/.test(letters) || letters.includes('Q')) return invalid(V.reasonLetters);
    return valid;
  }
}

/** Judges a [RomaniaPlates.temporary] value: a county code and three to six digits, the first `0` and the second not. */
export class RomaniaTemporaryValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonNumber = 'The number is three to six digits, the first 0 and the second not.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isCounty(entry.group('county'))) return invalid(RomaniaValidator.reasonCounty);
    const n = entry.group('number');
    if (n.length < 3 || !isDigits(n) || n[0] !== '0' || n[1] === '0') return invalid(RomaniaTemporaryValidator.reasonNumber);
    return valid;
  }
}

/** Judges a [RomaniaPlates.test] value: a county code and a three-digit number from 101. */
export class RomaniaTestValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonNumber = 'The number is three digits, from 101.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isCounty(entry.group('county'))) return invalid(RomaniaValidator.reasonCounty);
    const n = entry.group('number');
    if (!isDigitsOfLength(n, 3) || Number(n) < 101) return invalid(RomaniaTestValidator.reasonNumber);
    return valid;
  }
}

/**
 * Judges a [RomaniaPlates.diplomatic] value: `CD`, `TC` or `CO` and two
 * three-digit codes, the lowest of either being 101. The article's table of
 * mission codes is partial, so the mission code is only range-checked.
 */
export class RomaniaDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'rank';

  static readonly reasonCode = 'The code is CD, TC or CO.';
  static readonly reasonDigits = 'The mission and the rank are each three digits, from 101.';

  judge(entry: PlateEntry): PlateValidation {
    if (!['CD', 'TC', 'CO'].includes(entry.group('code'))) return invalid(RomaniaDiplomaticValidator.reasonCode);
    for (const key of ['mission', 'rank']) {
      const v = entry.group(key);
      if (!isDigitsOfLength(v, 3) || Number(v) < 101) return invalid(RomaniaDiplomaticValidator.reasonDigits);
    }
    return valid;
  }
}

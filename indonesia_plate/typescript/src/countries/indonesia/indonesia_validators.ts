import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from 'plate_core/core/validators/plate_validator';

/** The area codes a plate's prefix may be, grouped by island. */
export const IndonesiaAreaCodes = {
  all: new Set(
    [
      // Sumatra
      'BL BB BK BA BM BP BH BD BG BN BE',
      // Java
      'A B F T E D Z R G H K AA AD AB AE AG S W L M N P',
      // Kalimantan
      'KB KH DA KT KU',
      // Sulawesi
      'DL DB DM DN DC DP DW DD DT',
      // Nusa Tenggara
      'DK DR EA ED EB DH',
      // Maluku and Papua
      'DE DG PA PB PG PS PT PY',
      // Non-motorised
      'SB YB YK KS',
    ].flatMap((row) => row.split(' ')),
  ) as ReadonlySet<string>,
};

/** The police-region numerals over the serial of a Polri plate: the Roman numbers I to XXXV. */
const policeRegions: ReadonlySet<string> = new Set(
  'I II III IV V VI VII VIII IX X XI XII XIII XIV XV XVI XVII XVIII XIX XX XXI XXII XXIII XXIV XXV XXVI XXVII XXVIII XXIX XXX XXXI XXXII XXXIII XXXIV XXXV'.split(' '),
);

/** Judges an Indonesian plate: area code, number, optional suffix letters and expiry month. Reports, never bars a keystroke. */
export class IndonesiaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonArea = 'Not an Indonesian area code.';
  static readonly reasonNumber = 'The number is 1 to 9999.';
  static readonly reasonLeadingZero = 'The number has no leading zero.';
  static readonly reasonSuffix = 'The suffix is up to three letters.';
  static readonly reasonMonth = 'The expiry month is 01 to 12.';

  judge(entry: PlateEntry): PlateValidation {
    return IndonesiaValidator.validateFields({
      prefix: entry.group('prefix'),
      number: entry.group('number'),
      suffix: entry.group('suffix'),
      month: entry.group('month'),
    });
  }

  static validateFields({ prefix, number, suffix = '', month = '' }: { prefix: string; number: string; suffix?: string; month?: string }): PlateValidation {
    if (!IndonesiaAreaCodes.all.has(prefix)) return invalid(IndonesiaValidator.reasonArea);
    if (number === '' || number.length > 4 || !isDigits(number)) return invalid(IndonesiaValidator.reasonNumber);
    if (number.startsWith('0')) return invalid(IndonesiaValidator.reasonLeadingZero);
    if (suffix.length > 3) return invalid(IndonesiaValidator.reasonSuffix);
    if (month !== '') {
      const m = isDigits(month) ? Number(month) : null;
      if (month.length !== 2 || m === null || m < 1 || m > 12) return invalid(IndonesiaValidator.reasonMonth);
    }
    return valid;
  }
}

/** Judges a diplomatic plate: `CD` or `CC`, a country number and a serial. */
export class IndonesiaDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonMission = 'The code is CD or CC.';
  static readonly reasonDigits = 'Both numbers are digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!['CD', 'CC'].includes(entry.group('mission'))) return invalid(IndonesiaDiplomaticValidator.reasonMission);
    return isDigits(entry.group('country')) && isDigits(entry.group('serial')) ? valid : invalid(IndonesiaDiplomaticValidator.reasonDigits);
  }
}

/** Judges a Polri service plate: number, two-digit suffix and, where the spec has one, the police-region numeral. */
export class IndonesiaServiceValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonNumber = 'The number is 1 to 99999.';
  static readonly reasonSuffix = 'The suffix is two digits.';
  static readonly reasonRegion = 'Not a police region numeral.';

  judge(entry: PlateEntry): PlateValidation {
    const number = entry.group('number');
    if (number === '' || !isDigits(number) || number.startsWith('0')) return invalid(IndonesiaServiceValidator.reasonNumber);
    if (!isDigitsOfLength(entry.group('suffix'), 2)) return invalid(IndonesiaServiceValidator.reasonSuffix);
    if (entry.spec.textGroups.some((g) => g.key === 'region') && !policeRegions.has(entry.group('region'))) return invalid(IndonesiaServiceValidator.reasonRegion);
    return valid;
  }
}

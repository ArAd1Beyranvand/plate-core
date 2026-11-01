import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a Kosovar plate field by field.
 *
 * Formats (the article gives `01 234-AB`; the rest are read off the
 * pictures): private, trailer, agriculture and moped a district code, three
 * digits and two letters; government an agency code (digit and letter), three digits and two digits;
 * police and emergency digits throughout; customs three digits and two
 * letters; Security Force `KSF`, three digits and two digits; the UNMIK-style
 * plate three digits, two letters and three digits; diplomatic a code, two
 * letters and three digits; EULEX four digits. The serial of a plate is not
 * held to the article's 101 floor, which the pictures do not bear out.
 * Reports, never bars a keystroke. */
export class KosovoValidator extends GatedPlateValidator {
  readonly gateGroup = 'series';

  static readonly reason = 'The plate does not match its format.';
  static readonly reasonDistrict = 'The district code is 01 to 07.';

  private static readonly _district = /^0[1-7]$/;
  private static readonly _twoDigits = /^\d{2}$/;
  private static readonly _threeDigits = /^\d{3}$/;
  private static readonly _twoLetters = /^[A-Z]{2}$/;

  private static readonly _districtPlate: Record<string, RegExp> = {
    region: KosovoValidator._district,
    serial: KosovoValidator._threeDigits,
    series: KosovoValidator._twoLetters,
  };

  private static readonly _formats: Record<string, Record<string, RegExp>> = {
    'xk.private': KosovoValidator._districtPlate,
    'xk.agriculture': KosovoValidator._districtPlate,
    'xk.trailer': KosovoValidator._districtPlate,
    'xk.moped': KosovoValidator._districtPlate,
    'xk.government': { agency: /^\d[A-Z]$/, serial: KosovoValidator._threeDigits, series: KosovoValidator._twoDigits },
    'xk.police': { serial: KosovoValidator._threeDigits, series: KosovoValidator._twoDigits },
    'xk.emergency': { service: KosovoValidator._threeDigits, serial: KosovoValidator._threeDigits, series: KosovoValidator._twoDigits },
    'xk.customs': { serial: KosovoValidator._threeDigits, series: KosovoValidator._twoLetters },
    'xk.military': { unit: /^[A-Z]{3}$/, serial: KosovoValidator._threeDigits, series: KosovoValidator._twoDigits },
    'xk.unmik': { serial: KosovoValidator._threeDigits, mark: KosovoValidator._twoLetters, series: KosovoValidator._threeDigits },
    'xk.diplomatic': { region: KosovoValidator._twoDigits, mark: KosovoValidator._twoLetters, series: KosovoValidator._threeDigits },
    'xk.eulex': { series: /^\d{4}$/ },
  };

  judge(entry: PlateEntry): PlateValidation {
    const format = KosovoValidator._formats[entry.spec.id];
    if (format === undefined) return valid;
    for (const [key, pattern] of Object.entries(format)) {
      if (!pattern.test(entry.group(key))) {
        return invalid(key === 'region' ? KosovoValidator.reasonDistrict : KosovoValidator.reason);
      }
    }
    return valid;
  }
}

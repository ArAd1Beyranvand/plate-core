import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid, isLetters } from '../../core/validators/plate_validator';

const numberRe = /^[0-9]{1,5}$/;
const countryRe = /^[0-9]{3}$/;

/**
 * Advisory validator over whichever of `number`, `series` (first letter the
 * province) and `country` (diplomatic code) the spec has. Empty groups are
 * not judged.
 */
export class MadagascarValidator implements PlateValidator {
  static readonly provinces: ReadonlySet<string> = new Set(['A', 'D', 'F', 'M', 'T', 'U']);
  static readonly diplomaticSeries: ReadonlySet<string> = new Set(['CD', 'CMD', 'CMC', 'PE']);

  static readonly reasonNumber = 'The number is one to five digits.';
  static readonly reasonSeries = 'The series is two or three letters.';
  static readonly reasonProvince = 'The first letter is the province: A, D, F, M, T or U.';
  static readonly reasonCountry = 'The country code is three digits.';
  static readonly reasonDiplomatic = 'The series is CD, CMD, CMC or PE.';

  validate(entry: PlateEntry): PlateValidation {
    const V = MadagascarValidator;
    const broken = restrictionVerdict(entry);
    if (broken !== null) return broken;
    const number = entry.group('number');
    const series = entry.group('series');
    const country = entry.group('country');
    if (number !== '' && !numberRe.test(number)) return invalid(V.reasonNumber);
    if (country !== '') {
      if (!countryRe.test(country)) return invalid(V.reasonCountry);
      if (series !== '' && !V.diplomaticSeries.has(series)) return invalid(V.reasonDiplomatic);
    } else if (series !== '') {
      if (!isLetters(series, 1, 3)) return invalid(V.reasonSeries);
      // The province letter leads a standard series; the dealer plate prints
      // only the province, and the temporary series leads with `WW`.
      const province = series.startsWith('WW') ? series.slice(-1) : series[0];
      if (series.length > 1 && !V.provinces.has(province)) return invalid(V.reasonProvince);
    }
    return valid;
  }
}

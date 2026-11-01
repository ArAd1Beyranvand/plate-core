import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** The article's table of series letters: thirty-nine Thai consonants. */
const seriesLetters = 'ก ข ค ง จ ฉ ช ฌ ฏ ฐ ณ ด ต ถ ท ธ น บ ป ผ พ ฟ ภ ม ย ร ล ว ศ ษ ส ห ฬ อ ฮ ญ ฒ ฆ ซ'.split(' ');

/** Judges by the registers the spec has: an optional leading digit, the
 * series letters, and a serial of one to four digits without leading zeroes
 * (bus and truck plates print two series digits and four serial digits,
 * zeroes kept). Reports, never bars a keystroke. */
export class ThailandValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLead = 'A leading digit is 1 to 9.';
  static readonly reasonSeries = 'The series is Thai consonants.';
  static readonly reasonPrefix = 'The series is two digits.';
  static readonly reasonSerial = 'The number is 1 to 9999.';
  static readonly reasonTruckSerial = 'The number is four digits.';
  static readonly reasonCode = 'The province code is two digits.';

  private static readonly _leadDigit = /^[1-9]$/;
  private static readonly _serial = /^[1-9][0-9]{0,3}$/;

  judge(entry: PlateEntry): PlateValidation {
    const spec = entry.spec;
    const lead = entry.group('lead');
    if (spec.indicesOfGroup('lead').length > 0 && lead !== '' && !ThailandValidator._leadDigit.test(lead)) {
      return invalid(ThailandValidator.reasonLead);
    }
    const letters = spec.indicesOfGroup('series').length;
    if (letters > 0) {
      const series = Array.from(entry.group('series'));
      if (series.length !== letters || !series.every((c) => seriesLetters.includes(c))) {
        return invalid(ThailandValidator.reasonSeries);
      }
    }
    if (spec.indicesOfGroup('prefix').length > 0) {
      if (!isDigitsOfLength(entry.group('prefix'), 2)) {
        return invalid(ThailandValidator.reasonPrefix);
      }
      if (!isDigitsOfLength(entry.group('serial'), 4)) {
        return invalid(ThailandValidator.reasonTruckSerial);
      }
      const code = entry.group('code');
      if (code !== '' && !isDigitsOfLength(code, 2)) {
        return invalid(ThailandValidator.reasonCode);
      }
      return valid;
    }
    return ThailandValidator._serial.test(entry.group('serial')) ? valid : invalid(ThailandValidator.reasonSerial);
  }
}

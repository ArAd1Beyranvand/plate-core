import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

const unissued = /[IO]/;

/**
 * Judges a `BruneiPlates.singleRow` registration. Reports, never bars a
 * keystroke.
 *
 * Series run `B 1`-`BZZ 9999` and `KA 1`-`KP 9999`: a prefix starts with B or
 * K, a lone K is never issued, a K series' second letter is A-P, I and O are
 * never issued, and the number is 1-9999 without leading zero. `MOD` plus a
 * number and branch letter is exempt from the letter rules. Released prefixes
 * and royal vanity plates are not checked.
 */
export class BruneiValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly military = 'MOD';

  static readonly reasonPrefixMissing = 'A plate starts with letters.';
  static readonly reasonSeries = 'A plate starts with B or K, or is MOD.';
  static readonly reasonLoneK = 'There is no plate with the single letter K.';
  static readonly reasonKSeries = 'A K series runs from KA to KP.';
  static readonly reasonNoIO = 'I and O are not issued on Brunei plates.';
  static readonly reasonNumber = 'The number is 1 to 9999.';
  static readonly reasonLeadingZero = 'The number has no leading zero.';
  static readonly reasonSuffix = 'Only a MOD plate has a branch letter.';

  judge(entry: PlateEntry): PlateValidation {
    return BruneiValidator.validateFields({ prefix: entry.group('prefix'), number: entry.group('number'), suffix: entry.group('suffix') });
  }

  static validateFields({ prefix, number, suffix = '' }: { prefix: string; number: string; suffix?: string }): PlateValidation {
    if (prefix === '') return invalid(BruneiValidator.reasonPrefixMissing);
    if (prefix !== BruneiValidator.military) {
      if (prefix[0] !== 'B' && prefix[0] !== 'K') return invalid(BruneiValidator.reasonSeries);
      if (unissued.test(prefix + suffix)) return invalid(BruneiValidator.reasonNoIO);
      if (prefix[0] === 'K') {
        if (prefix.length === 1) return invalid(BruneiValidator.reasonLoneK);
        if (prefix.charCodeAt(1) > 80) return invalid(BruneiValidator.reasonKSeries);
      }
      if (suffix !== '') return invalid(BruneiValidator.reasonSuffix);
    }
    if (number === '' || number.length > 4 || !isDigits(number)) return invalid(BruneiValidator.reasonNumber);
    if (number.startsWith('0')) return invalid(BruneiValidator.reasonLeadingZero);
    return valid;
  }
}

/**
 * Judges a `BruneiPlates.diplomatic` value: two numbers of one or two digits.
 * No ranges are documented.
 */
export class BruneiDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'mission';

  static readonly reasonDigits = 'Each number is one or two digits.';

  judge(entry: PlateEntry): PlateValidation {
    for (const part of [entry.group('serial'), entry.group('mission')]) {
      if (part === '' || part.length > 2 || !isDigits(part)) return invalid(BruneiDiplomaticValidator.reasonDigits);
    }
    return valid;
  }
}

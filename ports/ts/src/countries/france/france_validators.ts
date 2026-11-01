import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

const letterPair = /^[A-HJ-NP-TV-Z]{2}$/;
const departmentPattern = /^(0[1-9]|1\d|2[1-9]|[3-8]\d|9[0-5]|2A|2B)$/;
const monthPattern = /^(0[1-9]|1[0-2])$/;

/**
 * Judges a French SIV plate: two letters, three digits (001–999) and two
 * letters, with a département code on the right when the plate has one, or a
 * month and year on a dated plate. The letters leave out I, O and U, and the
 * SS pair. Regular plates never start WW; `temporary` plates always do.
 * Reports, never bars a keystroke.
 */
export class FranceValidator extends GatedPlateValidator {
  readonly temporary: boolean;

  constructor({ temporary = false }: { readonly temporary?: boolean } = {}) {
    super();
    this.temporary = temporary;
  }

  readonly gateGroup = 'number';

  static readonly reasonPrefix = 'The prefix is two letters (no I, O, U or SS).';
  static readonly reasonTemporary = 'A temporary plate starts WW.';
  static readonly reasonNumber = 'The number is three digits, 001–999.';
  static readonly reasonSuffix = 'The suffix is two letters (no I, O, U or SS).';
  static readonly reasonDepartment = 'The département is two digits (01–95), 2A or 2B.';
  static readonly reasonMonth = 'The month is 01–12.';
  static readonly reasonYear = 'The year is two digits.';

  judge(entry: PlateEntry): PlateValidation {
    const prefix = entry.group('prefix');
    if (!letterPair.test(prefix) || prefix === 'SS') return invalid(FranceValidator.reasonPrefix);
    if (this.temporary !== (prefix === 'WW')) return invalid(FranceValidator.reasonTemporary);
    const number = entry.group('number');
    if (!isDigitsOfLength(number, 3) || number === '000') return invalid(FranceValidator.reasonNumber);
    const suffix = entry.group('suffix');
    if (!letterPair.test(suffix) || suffix === 'SS') return invalid(FranceValidator.reasonSuffix);
    const department = entry.group('department');
    if (department !== '' && !departmentPattern.test(department)) return invalid(FranceValidator.reasonDepartment);
    const month = entry.group('month');
    if (month !== '' && !monthPattern.test(month)) return invalid(FranceValidator.reasonMonth);
    const year = entry.group('year');
    if (year !== '' && !isDigitsOfLength(year, 2)) return invalid(FranceValidator.reasonYear);
    return valid;
  }
}

/**
 * Judges a diplomatic plate: one to three digits for the embassy, a status
 * (`C` consulate, `CD` embassy, `CMD` ambassador, `K` technical staff) and a
 * series of one to three digits. Reports, never bars a keystroke, except for
 * the spec's restrictions.
 */
export class FranceDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'embassy';

  static readonly reasonEmbassy = 'The embassy code is one to three digits.';
  static readonly reasonStatus = 'The status is C, CD, CMD or K.';
  static readonly reasonSeries = 'The series is one to three digits.';
  static readonly statuses: readonly string[] = ['C', 'CD', 'CMD', 'K'];

  judge(entry: PlateEntry): PlateValidation {
    const embassy = entry.group('embassy');
    if (!isDigits(embassy) || embassy.length > 3) return invalid(FranceDiplomaticValidator.reasonEmbassy);
    if (!FranceDiplomaticValidator.statuses.includes(entry.group('status'))) return invalid(FranceDiplomaticValidator.reasonStatus);
    const series = entry.group('series');
    return isDigits(series) && series.length <= 3 ? valid : invalid(FranceDiplomaticValidator.reasonSeries);
  }
}

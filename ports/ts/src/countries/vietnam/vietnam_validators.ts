import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

const refusedMissions = ['336', '337', '338', '339', '340'];
const notFound = 'COUNTRY NOT FOUND';

/** The number, whole: a dot or dash splits it into `number`, `number2`. */
const number = (entry: PlateEntry): string => entry.group('number') + entry.group('number2') + entry.group('number3');

/** Judges a civil, temporary or motorcycle plate: a province code, a series
 * and a number. Reports, never bars a keystroke.
 *
 * Checks what QCVN 08:2024/BCA and the article state: the province code is
 * two digits from 11 up (there is no 00 to 10), the series is letters from
 * the issued alphabet, and the number is five digits (`256.58`). Does not check which
 * province codes or series have actually been issued. */
export class VietnamValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonProvince = 'The province code is 11 to 99.';
  static readonly reasonSeries = 'The series is missing.';
  static readonly reasonNumber = 'The number is 5 digits.';

  judge(entry: PlateEntry): PlateValidation {
    const province = entry.group('province');
    if (province.length !== 2 || !isDigits(province) || parseInt(province, 10) < 11) {
      return invalid(VietnamValidator.reasonProvince);
    }
    if (entry.group('series') === '') {
      return invalid(VietnamValidator.reasonSeries);
    }
    const n = number(entry);
    return n.length === 5 && isDigits(n) ? valid : invalid(VietnamValidator.reasonNumber);
  }
}

/** Judges a diplomatic, international-organisation or foreigner plate: the
 * province, the mission's three-digit code and a two-digit number. Refuses
 * the codes 336 to 340. */
export class VietnamForeignValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonMission = 'The mission code is three digits.';
  static readonly reasonNumber = 'The number is two digits.';

  judge(entry: PlateEntry): PlateValidation {
    const mission = entry.group('mission');
    if (refusedMissions.includes(mission)) {
      return invalid(notFound);
    }
    if (mission.length !== 3 || !isDigits(mission)) {
      return invalid(VietnamForeignValidator.reasonMission);
    }
    const n = number(entry);
    return n.length === 2 && isDigits(n) ? valid : invalid(VietnamForeignValidator.reasonNumber);
  }
}

/** Judges a military plate: a two-letter unit code and the number. */
export class VietnamMilitaryValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonUnit = 'The unit code is two letters.';
  static readonly reasonNumber = 'The number is 3 or 4 digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('unit').length !== 2) {
      return invalid(VietnamMilitaryValidator.reasonUnit);
    }
    const n = number(entry);
    return n.length >= 3 && n.length <= 4 && isDigits(n) ? valid : invalid(VietnamMilitaryValidator.reasonNumber);
  }
}

import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/**
 * Judges a plate of the 2020 series: `BAGMATI B AB 0123`. Reports, never bars
 * a keystroke.
 *
 * Groups: `province`, `class` (`A`–`K`, or a sub-class such as `C1`),
 * `series` (two letters) and `number` (four digits).
 */
export class NepalValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('province') === '') return invalid('Choose a province.');
    if (!/^[A-K][1-5]?$/.test(entry.group('class'))) return invalid('The class is a letter A to K, with a digit for a sub-class.');
    if (!/^[A-Z]{2}$/.test(entry.group('series'))) return invalid('The series is two letters.');
    if (!isDigitsOfLength(entry.group('number'), 4)) return invalid('The number is 4 digits.');
    return valid;
  }
}

/**
 * Judges a plate of the 1983–2019 series: zone, a one or two digit lot, a
 * class letter and four digits (`X # X ####`).
 */
export class NepalLegacyValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('zone') === '') return invalid('Choose a zone.');
    if (!/^[0-9]{1,2}$/.test(entry.group('lot'))) return invalid('The lot is 1 or 2 digits.');
    if (entry.group('class') === '') return invalid('Choose a class letter.');
    if (!isDigitsOfLength(entry.group('number'), 4)) return invalid('The number is 4 digits.');
    return valid;
  }
}

/**
 * Judges a 1983–2019 diplomatic plate: a country or organisation number, the
 * fixed `C.D.` and a serial, each 1 or 2 digits.
 */
export class NepalDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  judge(entry: PlateEntry): PlateValidation {
    const digits = /^[0-9]{1,2}$/;
    if (!digits.test(entry.group('country'))) return invalid('The country number is 1 or 2 digits.');
    if (!digits.test(entry.group('serial'))) return invalid('The serial is 1 or 2 digits.');
    return valid;
  }
}

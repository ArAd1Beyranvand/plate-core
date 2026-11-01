import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** An ordinary registration on `TunisiaPlates.standard` or `square`: a series
 * of up to three digits with no leading zero (older series stay on the
 * road), then a registration of 0001-9999. Reports, never bars a keystroke. */
export class TunisiaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonSeries = 'The series is 1 to 999.';
  static readonly reasonNumber = 'The registration is four digits.';
  static readonly reasonZero = 'The registration is 0001 to 9999.';

  judge(entry: PlateEntry): PlateValidation {
    return TunisiaValidator.validateFields({ series: entry.group('series'), number: entry.group('number') });
  }

  static validateFields({ series, number }: { series: string; number: string }): PlateValidation {
    if (series === '' || series.length > 3 || !isDigits(series) || series.startsWith('0')) {
      return invalid(TunisiaValidator.reasonSeries);
    }
    if (!isDigitsOfLength(number, 4)) {
      return invalid(TunisiaValidator.reasonNumber);
    }
    if (number === '0000') {
      return invalid(TunisiaValidator.reasonZero);
    }
    return valid;
  }
}

/** A two-digit ministry code and the vehicle's number. */
export class TunisiaGovernmentValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonMinistry = 'The ministry code is two digits.';
  static readonly reasonNumber = 'The vehicle number is one to six digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('ministry'), 2)) {
      return invalid(TunisiaGovernmentValidator.reasonMinistry);
    }
    const number = entry.group('number');
    if (!isDigits(number) || number.length > 6) {
      return invalid(TunisiaGovernmentValidator.reasonNumber);
    }
    return valid;
  }
}

/** Two two-digit numbers. An ambassador's `CMD` plate always ends `01`; pass
 * `chief` for that spec. */
export class TunisiaDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';
  readonly chief: boolean;

  constructor({ chief = false }: { chief?: boolean } = {}) {
    super();
    this.chief = chief;
  }

  static readonly reasonDigits = 'Both numbers are two digits.';
  static readonly reasonChief = "A head of mission's plate ends 01.";

  judge(entry: PlateEntry): PlateValidation {
    const serial = entry.group('serial');
    if (!isDigitsOfLength(entry.group('country'), 2) || !isDigitsOfLength(serial, 2)) {
      return invalid(TunisiaDiplomaticValidator.reasonDigits);
    }
    if (this.chief && serial !== '01') {
      return invalid(TunisiaDiplomaticValidator.reasonChief);
    }
    return valid;
  }
}

/** The five-digit serial of a military or temporary plate. */
export class TunisiaSerialValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonSerial = 'The serial is five digits.';

  judge(entry: PlateEntry): PlateValidation {
    return isDigitsOfLength(entry.group('serial'), 5) ? valid : invalid(TunisiaSerialValidator.reasonSerial);
  }
}

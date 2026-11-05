import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from 'plate_core/core/validators/plate_validator';

const isRegion = (v: string): boolean => /^[1-8]$/.test(v);

/** Judges a `NigerPlates` value: region digit 1–8, one series letter, a four-digit serial. */
export class NigerValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonRegion = 'The region is a digit from 1 to 8.';
  static readonly reasonSeries = 'The series is one letter.';
  static readonly reasonSerial = 'The serial is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    return NigerValidator.validateFields({ region: entry.group('region'), series: entry.group('series'), serial: entry.group('serial') });
  }

  static validateFields(o: { region: string; series: string; serial: string }): PlateValidation {
    if (!isRegion(o.region)) return invalid(NigerValidator.reasonRegion);
    if (!/^[A-Z]$/.test(o.series)) return invalid(NigerValidator.reasonSeries);
    if (!isDigitsOfLength(o.serial, 4)) return invalid(NigerValidator.reasonSerial);
    return valid;
  }
}

/** `12345ARN6`: five digits, the fixed `ARN`, and a region digit. */
export class NigerStateValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('serial'), 5)) return invalid('The serial is five digits.');
    if (!isRegion(entry.group('area'))) return invalid(NigerValidator.reasonRegion);
    return valid;
  }
}

export class NigerMilitaryValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  judge(entry: PlateEntry): PlateValidation {
    return isDigitsOfLength(entry.group('serial'), 5) ? valid : invalid('The serial is five digits.');
  }
}

/**
 * `123CMD RN` and `123CD4 RN`: a three-digit country code, and for staff a
 * further digit the article calls the room.
 */
export class NigerDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'code';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('code'), 3)) return invalid('The country code is three digits.');
    const room = entry.group('room');
    if (room !== '' && !isDigitsOfLength(room, 1)) return invalid('The room is one digit.');
    return valid;
  }
}

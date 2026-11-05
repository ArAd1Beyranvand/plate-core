import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from 'plate_core/core/validators/plate_validator';

/** Wilaya codes 01–69: the original 48, those issued since 2022, and those accepted from 2027. */
const wilayas: ReadonlySet<string> = new Set(Array.from({ length: 69 }, (_, i) => String(i + 1).padStart(2, '0')));

/** Judges a civil plate: five-digit serial, class digit 1–9 plus two year digits, and a known wilaya. */
export class AlgeriaValidator extends GatedPlateValidator {
  readonly gateGroup = 'wilaya';

  static readonly reasonSerial = 'The serial is five digits.';
  static readonly reasonClass = 'The vehicle class is 1 to 9.';
  static readonly reasonType = 'The middle group is a class digit and two year digits.';
  static readonly reasonWilaya = 'The wilaya code is 01 to 69.';

  judge(entry: PlateEntry): PlateValidation {
    return AlgeriaValidator.validateFields(entry.group('serial'), entry.group('type'), entry.group('wilaya'));
  }

  static validateFields(serial: string, type: string, wilaya: string): PlateValidation {
    if (!isDigitsOfLength(serial, 5)) return invalid(AlgeriaValidator.reasonSerial);
    if (!isDigitsOfLength(type, 3)) return invalid(AlgeriaValidator.reasonType);
    if (type[0] === '0') return invalid(AlgeriaValidator.reasonClass);
    if (!wilayas.has(wilaya)) return invalid(AlgeriaValidator.reasonWilaya);
    return valid;
  }
}

/** Judges a diplomatic plate: a serial and two two-digit codes. */
export class AlgeriaDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'mission';

  static readonly reasonDigits = 'A diplomatic plate is a serial and two two-digit codes.';

  judge(entry: PlateEntry): PlateValidation {
    const serial = entry.group('serial');
    return serial === '' || !isDigits(serial) || !isDigitsOfLength(entry.group('status'), 2) || !isDigitsOfLength(entry.group('mission'), 2)
      ? invalid(AlgeriaDiplomaticValidator.reasonDigits)
      : valid;
  }
}

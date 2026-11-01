import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid, isLetters } from '../../core/validators/plate_validator';

const classPattern = /^[0-9]{2}[0-9A-Z]?$/;
const serialPattern = /^(・・|・[0-9]|[0-9]{2})[0-9]{2}$/;

/** Judges a Japanese plate: office, class code, kana and a four-place serial; export and diplomatic plates have their own shapes. Reports, never bars a keystroke. */
export class JapanValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonCar = 'A plate is an office, a class code, a hiragana and a four-place serial.';
  static readonly reasonClass = 'A class code is two digits, then a digit or a letter.';
  static readonly reasonSerial = 'A serial is four places; leading zeros are printed as dots.';
  static readonly reasonExport = 'An export plate is two or three letters, one or two letters and four digits.';
  static readonly reasonDiplomatic = 'A diplomatic plate is five digits.';

  judge(entry: PlateEntry): PlateValidation {
    const serial = entry.group('serial');
    const office = entry.group('office');
    const kana = entry.group('kana');
    if (office === '') return isDigitsOfLength(serial, 5) ? valid : invalid(JapanValidator.reasonDiplomatic);
    if (/^[A-Za-z]$/.test(office[0])) {
      return isLetters(office, 2, 3) && isLetters(kana, 1, 2) && isDigitsOfLength(serial, 4) ? valid : invalid(JapanValidator.reasonExport);
    }
    if (kana === '') return invalid(JapanValidator.reasonCar);
    if (entry.spec.indicesOfGroup('class').length > 0 && !classPattern.test(entry.group('class'))) return invalid(JapanValidator.reasonClass);
    return serialPattern.test(serial) ? valid : invalid(JapanValidator.reasonSerial);
  }
}

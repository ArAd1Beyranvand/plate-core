import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Libyan plate: a municipality code, a serial not starting with 0 and, on foreign plates, a country code. Reports, never bars a keystroke. */
export class LibyaPlateValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonMunicipality = 'Not a municipality code in the published table.';
  static readonly reasonSerial = 'The serial does not start with 0.';
  static readonly reasonCountry = 'Not a country code in the published table.';

  static readonly municipalities: ReadonlySet<number> = new Set(Array.from({ length: 67 }, (_, i) => i + 1).filter((n) => ![23, 29, 31, 34, 39].includes(n)));

  static readonly countries: ReadonlySet<number> = new Set([
    10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27,
    28, 30, 31, 32, 33, 34, 35, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
    48, 49, 50, 51, 52, 53, 54, 55, 56, 58, 59, 60, 61, 62, 63, 64, 65, 66,
    67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84,
    85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 99, 106, 108, 111,
    119, 120, 125, 130, 157, 180, 190,
  ]);

  judge(entry: PlateEntry): PlateValidation {
    const keys = new Set(entry.spec.textGroups.map((g) => g.key));
    if (keys.has('municipality')) {
      const m = entry.group('municipality');
      if (!isDigits(m) || !LibyaPlateValidator.municipalities.has(Number(m))) return invalid(LibyaPlateValidator.reasonMunicipality);
    }
    const s = entry.group('serial');
    if (!isDigits(s) || s.startsWith('0')) return invalid(LibyaPlateValidator.reasonSerial);
    if (keys.has('country')) {
      const c = entry.group('country');
      if (!isDigits(c) || !LibyaPlateValidator.countries.has(Number(c))) return invalid(LibyaPlateValidator.reasonCountry);
    }
    return valid;
  }
}

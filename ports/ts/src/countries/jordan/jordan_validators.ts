import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

const range = (from: number, to: number): string[] => Array.from({ length: to - from + 1 }, (_, i) => String(from + i));

/** The codes each Jordanian spec issues; a spec with none (the temporary plate) takes any. */
const codesOf: Readonly<Record<string, readonly string[]>> = {
  'jo.private': [...range(1, 49), '66', '77', '80', '81', '88'],
  'jo.motorcycle': ['46', '47'],
  'jo.transport': range(50, 60),
  'jo.rental': ['70'],
  'jo.trailer': ['71'],
  'jo.governmental': ['PM', 'PR', 'SN', 'JC', 'GV', 'AQ'],
  'jo.diplomatic': ['CD'],
  'jo.police': ['99'],
  'jo.ambulance': ['95'],
  'jo.gendarmerie': ['96'],
};

/** Judges a Jordanian plate: a code and a serial of one to five digits. Reports, never bars a keystroke. */
export class JordanValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonCodeMissing = 'A plate starts with a code.';
  static readonly reasonCodeUnknown = 'That code is not issued on this plate.';
  static readonly reasonSerialNotNumeric = 'The number is digits only.';
  static readonly reasonSerialLength = 'The number is one to five digits.';

  static readonly maxSerialLength = 5;

  judge(entry: PlateEntry): PlateValidation {
    const code = entry.group('code');
    const serial = entry.group('serial');
    if (code === '') return invalid(JordanValidator.reasonCodeMissing);
    const known = codesOf[entry.spec.id] ?? [];
    if (known.length > 0 && !known.includes(code)) return invalid(JordanValidator.reasonCodeUnknown);
    if (serial === '' || serial.length > JordanValidator.maxSerialLength) return invalid(JordanValidator.reasonSerialLength);
    return isDigits(serial) ? valid : invalid(JordanValidator.reasonSerialNotNumeric);
  }
}

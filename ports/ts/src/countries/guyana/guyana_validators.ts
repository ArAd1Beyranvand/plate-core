import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** Judges a Guyanese plate: two or three series letters and a one-to-four digit number with no leading zero. Reports, never bars a keystroke. */
export class GuyanaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly minLetters = 2;
  static readonly maxLetters = 3;
  static readonly maxDigits = 4;

  static readonly reasonLetters = 'The series is two or three letters.';
  static readonly reasonNumber = 'The number is one to four digits, with no leading zero.';

  judge(entry: PlateEntry): PlateValidation {
    return GuyanaValidator.validateFields({ letters: entry.group('letters'), number: entry.group('number') });
  }

  static validateFields({ letters, number }: { letters: string; number: string }): PlateValidation {
    if (!new RegExp(`^[A-Z]{${GuyanaValidator.minLetters},${GuyanaValidator.maxLetters}}$`).test(letters)) return invalid(GuyanaValidator.reasonLetters);
    if (!new RegExp(`^[1-9][0-9]{0,${GuyanaValidator.maxDigits - 1}}$`).test(number)) return invalid(GuyanaValidator.reasonNumber);
    return valid;
  }
}

/** The vehicle-type letters a Guyanese plate may open with, and what each means. */
export const GuyanaVehicleTypes = {
  names: {
    P: 'Private',
    H: 'Hire / taxi',
    B: 'Bus',
    G: 'Goods (powered trade vehicle)',
    C: 'Cycle',
    T: 'Trailer (non-powered trade vehicle)',
  } as Readonly<Record<string, string>>,
};

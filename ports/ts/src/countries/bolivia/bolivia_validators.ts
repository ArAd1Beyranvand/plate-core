import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/**
 * Judges a `BoliviaPlates.standard` value. Reports, never bars a keystroke.
 *
 * Checks what the article states: the PTA number is three or four digits
 * and three letters (`0XX AAA` on older vehicles to `64XX AAA` by December
 * 2024), and the box holds one of the nine department letters.
 */
export class BoliviaValidator extends GatedPlateValidator {
  readonly gateGroup = 'letters';

  static readonly reasonNumber = 'The number is three or four digits.';
  static readonly reasonLetters = 'The series is three letters.';
  static readonly reasonDepartment = 'The department is one of C H B L O N P S T.';

  judge(entry: PlateEntry): PlateValidation {
    return BoliviaValidator.validateFields({
      number: entry.group('number'),
      letters: entry.group('letters'),
      department: entry.group('department'),
    });
  }

  static validateFields({ number, letters, department }: { number: string; letters: string; department: string }): PlateValidation {
    if ((number.length !== 3 && number.length !== 4) || !isDigits(number)) return invalid(BoliviaValidator.reasonNumber);
    if (!/^[A-Z]{3}$/.test(letters)) return invalid(BoliviaValidator.reasonLetters);
    if (!/^[CHBLONPST]$/.test(department)) return invalid(BoliviaValidator.reasonDepartment);
    return valid;
  }
}

/** Judges a `BoliviaPlates.special` value: two two-digit numbers, the mission's country and the vehicle's rank. */
export class BoliviaSpecialValidator extends GatedPlateValidator {
  readonly gateGroup = 'rank';

  static readonly reasonDigits = 'Both numbers are two digits.';

  judge(entry: PlateEntry): PlateValidation {
    return isDigitsOfLength(entry.group('country'), 2) && isDigitsOfLength(entry.group('rank'), 2) ? valid : invalid(BoliviaSpecialValidator.reasonDigits);
  }
}

/** Judges a `BoliviaPlates.mercosur` value: two letters and five digits. */
export class BoliviaMercosurValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonLetters = 'The series is two letters.';
  static readonly reasonNumber = 'The number is five digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!/^[A-Z]{2}$/.test(entry.group('letters'))) return invalid(BoliviaMercosurValidator.reasonLetters);
    if (!isDigitsOfLength(entry.group('number'), 5)) return invalid(BoliviaMercosurValidator.reasonNumber);
    return valid;
  }
}

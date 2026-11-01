import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a plate: four digits (car, `1234`) or three letters over three
 * digits (motorcycle, `AAP 676`). Reports, never bars a keystroke. */
export class CookIslandsValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonCar = 'The number is four digits.';
  static readonly reasonLetters = 'The register is three letters.';
  static readonly reasonMotorcycle = 'The number is three digits.';

  judge(entry: PlateEntry): PlateValidation {
    const letters = entry.group('letters');
    const serial = entry.group('serial');
    if (entry.spec.slots.length === 1) {
      return isDigitsOfLength(serial, 4) ? valid : invalid(CookIslandsValidator.reasonCar);
    }
    if (!/^[A-Z]{3}$/.test(letters)) {
      return invalid(CookIslandsValidator.reasonLetters);
    }
    if (!isDigitsOfLength(serial, 3)) {
      return invalid(CookIslandsValidator.reasonMotorcycle);
    }
    return valid;
  }
}

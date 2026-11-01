import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a 2011 plate: three letters, three digits, two letters
 * (`GGE-123ZY`). Reports, never bars a keystroke.
 *
 * The article gives no format; the references (Lagos, Anambra, Kaduna,
 * Benue, Sokoto…) all print letters-digits-letters as 3-3-2. Plates of Kogi
 * and Niger mix letters and digits in the first field and are not modelled. */
export class NigeriaValidator extends GatedPlateValidator {
  readonly gateGroup = 'suffix';

  static readonly reasonArea = 'The area code is three letters.';
  static readonly reasonSerial = 'The number is three digits.';
  static readonly reasonSuffix = 'The suffix is two letters.';

  judge(entry: PlateEntry): PlateValidation {
    if (!/^[A-Z]{3}$/.test(entry.group('area')!)) {
      return invalid(NigeriaValidator.reasonArea);
    }
    if (!isDigitsOfLength(entry.group('serial')!, 3)) {
      return invalid(NigeriaValidator.reasonSerial);
    }
    if (!/^[A-Z]{2}$/.test(entry.group('suffix')!)) {
      return invalid(NigeriaValidator.reasonSuffix);
    }
    return valid;
  }
}

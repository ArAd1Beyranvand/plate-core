import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Micronesian plate: one `serial` group of four digits, the same on
 * the Kosrae, Pohnpei and Yap plates. Reports, never bars. */
export class FederatedStatesOfMicronesiaValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonSerial = 'The serial is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('serial'), 4)) {
      return invalid(FederatedStatesOfMicronesiaValidator.reasonSerial);
    }
    return valid;
  }
}

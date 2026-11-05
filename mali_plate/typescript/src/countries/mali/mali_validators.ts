import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from 'plate_core/core/validators/plate_validator';

/** Advisory validator for the `XX #### XX` format. */
export class MaliValidator extends GatedPlateValidator {
  readonly gateGroup = 'suffix';

  static readonly reasonFormat = 'Format is 2 letters, 4 digits, 2 letters.';

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('prefix').length !== 2 ||
        entry.group('number').length !== 4 ||
        entry.group('suffix').length !== 2) {
      return invalid(MaliValidator.reasonFormat);
    }
    return valid;
  }
}

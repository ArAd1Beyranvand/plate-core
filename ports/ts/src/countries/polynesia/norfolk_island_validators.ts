import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a `3◆203` value: a block digit 1 to 7, then three digits (leading
/// zeros are printed; cancelled blocks were reissued from 000). Reports,
/// never bars a keystroke. */
export class NorfolkIslandValidator extends GatedPlateValidator {
  readonly gateGroup = 'block';

  static readonly reasonBlock = 'The block is a digit from 1 to 7.';
  static readonly reasonSerial = 'The number is three digits.';

  private static readonly _block = new RegExp('^[1-7]$');

  judge(entry: PlateEntry): PlateValidation {
    if (!NorfolkIslandValidator._block.test(entry.group('block'))) {
      return invalid(NorfolkIslandValidator.reasonBlock);
    }
    if (!isDigitsOfLength(entry.group('serial'), 3)) {
      return invalid(NorfolkIslandValidator.reasonSerial);
    }
    return valid;
  }
}

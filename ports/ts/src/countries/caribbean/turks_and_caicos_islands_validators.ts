import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a [TurksAndCaicosIslandsPlates.modern] plate: five digits. Reports,
 * never bars a keystroke. */
export class TurksAndCaicosIslandsValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonSerial = 'The number is five digits.';

  judge(entry: PlateEntry): PlateValidation {
    return isDigitsOfLength(entry.group('serial'), 5) ? valid : invalid(TurksAndCaicosIslandsValidator.reasonSerial);
  }
}

/** Judges a [TurksAndCaicosIslandsPlates.prefixed] or `selfDrive` plate:
 * `TC` and one to five digits. */
export class TurksAndCaicosIslandsPrefixedValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonPrefix = 'The plate starts with TC.';
  static readonly reasonSerial = 'The number is one to five digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('prefix') !== 'TC') {
      return invalid(TurksAndCaicosIslandsPrefixedValidator.reasonPrefix);
    }
    if (!/^([0-9]{1,5})$/.test(entry.group('serial')!)) {
      return invalid(TurksAndCaicosIslandsPrefixedValidator.reasonSerial);
    }
    return valid;
  }
}

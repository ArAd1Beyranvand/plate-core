import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid, isLetters } from '../../core/validators/plate_validator';

const numberRe = /^[0-9]{4}$/;
const regions = /^(0[0-9]|1[0-2])$/;

/** Judges a `MauritaniaPlates` value, `NNNN LL RR`. Reports, never bars a keystroke. */
export class MauritaniaPlateValidator extends GatedPlateValidator {
  readonly gateGroup = 'region';

  static readonly reasonNumber = 'The number is four digits.';
  static readonly reasonLetters = 'The series is two letters.';
  static readonly reasonRegion = 'The region is 00 to 12.';

  judge(entry: PlateEntry): PlateValidation {
    const V = MauritaniaPlateValidator;
    if (!numberRe.test(entry.group('number'))) return invalid(V.reasonNumber);
    if (!isLetters(entry.group('letters'), 2)) return invalid(V.reasonLetters);
    if (!regions.test(entry.group('region'))) return invalid(V.reasonRegion);
    return valid;
  }
}

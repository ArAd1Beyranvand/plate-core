import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Burundian plate: a letter, four digits and a letter,
 * `A 0412 A`. Reports, never bars a keystroke.
 *
 * The format is read off two street photographs (`B·6232·A`, `A·0412·A`);
 * the article gives only "not standard". */
export class BurundiValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  private static readonly _letter = /^[A-Z]$/;

  judge(entry: PlateEntry): PlateValidation {
    if (!BurundiValidator._letter.test(entry.group('prefix')!)) {
      return invalid('The prefix is 1 letter.');
    }
    if (!isDigitsOfLength(entry.group('number')!, 4)) {
      return invalid('The number is 4 digits.');
    }
    if (!BurundiValidator._letter.test(entry.group('suffix')!)) {
      return invalid('The suffix is 1 letter.');
    }
    return valid;
  }
}

import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Pakistani registration: two or three letters (none of I, O, U),
 * three or four digits, and on Punjab's plate a two-digit year. Reports,
 * never bars a keystroke.
 *
 * Balochistan, Khyber Pakhtunkhwa and Punjab print four digits; Islamabad,
 * Azad Jammu & Kashmir and Sindh print three (the article: "two to three
 * numbers and three to four letters", the pictures show two or three letters
 * and three or four digits). */
export class PakistanValidator extends GatedPlateValidator {
  readonly gateGroup = 'digits';

  static readonly reasonLetters = 'The letters are two or three, none of I, O, U.';
  static readonly reasonDigits = 'The number is three or four digits.';
  static readonly reasonYear = 'The year is two digits.';

  private static readonly _letters = new RegExp('^[A-HJ-NP-TV-Z]{2,3}$');

  judge(entry: PlateEntry): PlateValidation {
    if (!PakistanValidator._letters.test(entry.group('letters'))) {
      return invalid(PakistanValidator.reasonLetters);
    }
    const digits = entry.group('digits');
    if (!isDigits(digits) || digits.length < 3 || digits.length > 4) {
      return invalid(PakistanValidator.reasonDigits);
    }
    const year = entry.group('year');
    if (year.length > 0 && !isDigitsOfLength(year, 2)) {
      return invalid(PakistanValidator.reasonYear);
    }
    return valid;
  }
}

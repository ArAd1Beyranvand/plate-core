import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid, isLetters } from '../../core/validators/plate_validator';

const missionClass = ['D', 'C', 'M', 'I', 'A'];
const mission1985Class = ['CD', 'CC', 'ME', 'OI', 'PA'];

/** Judges a Mercosur plate (`AB 123 CD`). Reports, never bars a keystroke. */
export class ArgentinaStandardValidator extends GatedPlateValidator {
  readonly gateGroup = 'series';

  static readonly reasonSeries = 'The series is two letters.';
  static readonly reasonNumber = 'The number is three digits.';
  static readonly reasonSuffix = 'The suffix is two letters.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isLetters(entry.group('series'), 2)) return invalid(ArgentinaStandardValidator.reasonSeries);
    if (!isDigitsOfLength(entry.group('number'), 3)) return invalid(ArgentinaStandardValidator.reasonNumber);
    if (!isLetters(entry.group('suffix'), 2)) return invalid(ArgentinaStandardValidator.reasonSuffix);
    return valid;
  }
}

/** Judges a 1995-series plate (`ABC 123`). */
export class ArgentinaLegacyValidator extends GatedPlateValidator {
  readonly gateGroup = 'series';

  static readonly reasonSeries = 'The series is three letters.';
  static readonly reasonNumber = 'The number is three digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isLetters(entry.group('series'), 3)) return invalid(ArgentinaLegacyValidator.reasonSeries);
    if (!isDigitsOfLength(entry.group('number'), 3)) return invalid(ArgentinaLegacyValidator.reasonNumber);
    return valid;
  }
}

/**
 * Judges a trailer plate (`101 ABC 123`): its own number, then the letters
 * and digits of the primary mover.
 */
export class ArgentinaTrailerValidator extends GatedPlateValidator {
  readonly gateGroup = 'trailer';

  static readonly reasonTrailer = 'The trailer number is three digits.';
  static readonly reasonSeries = "The mover's series is three letters.";
  static readonly reasonNumber = "The mover's number is three digits.";

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('trailer'), 3)) return invalid(ArgentinaTrailerValidator.reasonTrailer);
    if (!isLetters(entry.group('series'), 3)) return invalid(ArgentinaTrailerValidator.reasonSeries);
    if (!isDigitsOfLength(entry.group('number'), 3)) return invalid(ArgentinaTrailerValidator.reasonNumber);
    return valid;
  }
}

/**
 * Judges a 1995-series foreign-mission plate (`D 123 ABC`): one category
 * letter, three digits and three letters. The prefix is `D` diplomatic, `C`
 * consular, `M` special mission, `I` international organisation or `A`
 * administrative staff. The article prints `D 123 xx A`; the photographs
 * show three trailing letters, and the picture wins.
 */
export class ArgentinaMissionValidator extends GatedPlateValidator {
  readonly gateGroup = 'prefix';

  static readonly reasonNumber = 'The number is three digits.';
  static readonly reasonSuffix = 'The suffix is three letters.';

  judge(entry: PlateEntry): PlateValidation {
    if (!missionClass.includes(entry.group('prefix'))) return invalid('The category is D, C, M, I or A.');
    if (!isDigitsOfLength(entry.group('number'), 3)) return invalid(ArgentinaMissionValidator.reasonNumber);
    if (!isLetters(entry.group('suffix'), 3)) return invalid(ArgentinaMissionValidator.reasonSuffix);
    return valid;
  }
}

/**
 * Judges a 1985 foreign-mission plate (`CD-1234`). The prefix is `CD`
 * diplomatic, `CC` consular, `ME` special mission, `OI` international
 * organisation or `PA` administrative staff.
 */
export class ArgentinaMission1985Validator extends GatedPlateValidator {
  readonly gateGroup = 'prefix';

  static readonly reasonNumber = 'The number is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!mission1985Class.includes(entry.group('prefix'))) return invalid('The category is CD, CC, ME, OI or PA.');
    if (!isDigitsOfLength(entry.group('number'), 4)) return invalid(ArgentinaMission1985Validator.reasonNumber);
    return valid;
  }
}

import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

const letters2 = /^[A-Z]{2}$/;
const letter = /^[A-Z]$/;

/** Judges a private, repetitive or motorcycle plate (`AB 123 CD`; the motorcycle has no suffix). Reports, never bars a keystroke. */
export class AlbaniaPrivateValidator extends GatedPlateValidator {
  readonly gateGroup = 'series';

  static readonly reasonSeries = 'The series is two letters.';
  static readonly reasonNumber = 'The number is three digits.';
  static readonly reasonSuffix = 'The suffix is two letters.';

  judge(entry: PlateEntry): PlateValidation {
    if (!letters2.test(entry.group('series'))) {
      return invalid(AlbaniaPrivateValidator.reasonSeries);
    }
    if (!isDigitsOfLength(entry.group('number'), 3)) {
      return invalid(AlbaniaPrivateValidator.reasonNumber);
    }
    const suffix = entry.group('suffix');
    if (suffix !== '' && !letters2.test(suffix)) {
      return invalid(AlbaniaPrivateValidator.reasonSuffix);
    }
    return valid;
  }
}

/** Judges an agricultural, technological or trailer plate: `AB MB 78`, `AB MT 78`, `AB RB 78`, `AB RT 78` (two digits) or `AB R 456` (three). */
export class AlbaniaAgriculturalValidator extends GatedPlateValidator {
  readonly gateGroup = 'series';

  static readonly classes: readonly string[] = ['MB', 'MT', 'RB', 'RT', 'R'];

  static readonly reasonSeries = 'The series is two letters.';
  static readonly reasonClass = 'The class is MB, MT, RB, RT or R.';
  static readonly reasonNumber = 'The number is three digits after R, two after the others.';

  judge(entry: PlateEntry): PlateValidation {
    if (!letters2.test(entry.group('series'))) {
      return invalid(AlbaniaAgriculturalValidator.reasonSeries);
    }
    const kind = entry.group('class');
    if (!AlbaniaAgriculturalValidator.classes.includes(kind)) {
      return invalid(AlbaniaAgriculturalValidator.reasonClass);
    }
    if (!isDigitsOfLength(entry.group('number'), kind === 'R' ? 3 : 2)) {
      return invalid(AlbaniaAgriculturalValidator.reasonNumber);
    }
    return valid;
  }
}

/** Judges a diplomatic (`CD`) or service-diplomatic (`TR`) plate (`CD 12 03A`): the mission code, a two-digit number and a rank letter. */
export class AlbaniaDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'prefix';

  static readonly reasonPrefix = 'The prefix is CD or TR.';
  static readonly reasonCode = 'The mission code is two digits.';
  static readonly reasonNumber = 'The number is two digits.';
  static readonly reasonSuffix = 'The rank is one letter.';

  judge(entry: PlateEntry): PlateValidation {
    const prefix = entry.group('prefix');
    if (prefix !== 'CD' && prefix !== 'TR') {
      return invalid(AlbaniaDiplomaticValidator.reasonPrefix);
    }
    if (!isDigitsOfLength(entry.group('code'), 2)) {
      return invalid(AlbaniaDiplomaticValidator.reasonCode);
    }
    if (!isDigitsOfLength(entry.group('number'), 2)) {
      return invalid(AlbaniaDiplomaticValidator.reasonNumber);
    }
    if (!letter.test(entry.group('suffix'))) {
      return invalid(AlbaniaDiplomaticValidator.reasonSuffix);
    }
    return valid;
  }
}

/** Judges a military plate (`MM 123PU`): the ministry prefix, three digits and a branch code. */
export class AlbaniaMilitaryValidator extends GatedPlateValidator {
  readonly gateGroup = 'prefix';

  static readonly branches: readonly string[] = ['FA', 'FD', 'FT', 'KM', 'PU', 'SP'];

  static readonly reasonPrefix = 'The prefix is MM.';
  static readonly reasonNumber = 'The number is three digits.';
  static readonly reasonSuffix = 'The branch is FA, FD, FT, KM, PU or SP.';

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('prefix') !== 'MM') {
      return invalid(AlbaniaMilitaryValidator.reasonPrefix);
    }
    if (!isDigitsOfLength(entry.group('number'), 3)) {
      return invalid(AlbaniaMilitaryValidator.reasonNumber);
    }
    if (!AlbaniaMilitaryValidator.branches.includes(entry.group('suffix'))) {
      return invalid(AlbaniaMilitaryValidator.reasonSuffix);
    }
    return valid;
  }
}

/** Judges a police plate (`MB 123 AB`): the ministry prefix, three digits and two letters. */
export class AlbaniaPoliceValidator extends GatedPlateValidator {
  readonly gateGroup = 'prefix';

  static readonly reasonPrefix = 'The prefix is MB.';
  static readonly reasonNumber = 'The number is three digits.';
  static readonly reasonSuffix = 'The suffix is two letters.';

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('prefix') !== 'MB') {
      return invalid(AlbaniaPoliceValidator.reasonPrefix);
    }
    if (!isDigitsOfLength(entry.group('number'), 3)) {
      return invalid(AlbaniaPoliceValidator.reasonNumber);
    }
    if (!letters2.test(entry.group('suffix'))) {
      return invalid(AlbaniaPoliceValidator.reasonSuffix);
    }
    return valid;
  }
}

/** Judges a taxi plate (`AB 123 T`). */
export class AlbaniaTaxiValidator extends GatedPlateValidator {
  readonly gateGroup = 'series';

  static readonly reasonSeries = 'The series is two letters.';
  static readonly reasonNumber = 'The number is three digits.';
  static readonly reasonSuffix = 'A taxi plate ends in T.';

  judge(entry: PlateEntry): PlateValidation {
    if (!letters2.test(entry.group('series'))) {
      return invalid(AlbaniaTaxiValidator.reasonSeries);
    }
    if (!isDigitsOfLength(entry.group('number'), 3)) {
      return invalid(AlbaniaTaxiValidator.reasonNumber);
    }
    if (entry.group('suffix') !== 'T') {
      return invalid(AlbaniaTaxiValidator.reasonSuffix);
    }
    return valid;
  }
}

/** Judges a temporary (`AB 0 PRK`) or test (`AB 0 PROV`) plate. */
export class AlbaniaProvisionalValidator extends GatedPlateValidator {
  readonly gateGroup = 'series';

  static readonly reasonSeries = 'The series is two letters.';
  static readonly reasonNumber = 'The number is one digit.';
  static readonly reasonWord = 'The word is PRK (temporary) or PROV (test).';

  judge(entry: PlateEntry): PlateValidation {
    if (!letters2.test(entry.group('series'))) {
      return invalid(AlbaniaProvisionalValidator.reasonSeries);
    }
    if (!isDigitsOfLength(entry.group('number'), 1)) {
      return invalid(AlbaniaProvisionalValidator.reasonNumber);
    }
    const word = entry.group('word');
    if (word !== 'PRK' && word !== 'PROV') {
      return invalid(AlbaniaProvisionalValidator.reasonWord);
    }
    return valid;
  }
}

import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from 'plate_core/core/validators/plate_validator';

const governorateLetters = 'ABCDEFGHJKLMN';
const legacyDistricts = '13456789';
const twoDigits = /^[0-9]{2}$/;

/** Whether the two-digit legacy usage `code` is a legal class: 30-32, 40-49 or 90-99. */
const legacyUsageOk = (code: string): boolean => {
  if (!twoDigits.test(code)) return false;
  const n = Number(code);
  return (n >= 30 && n <= 32) || (n >= 40 && n <= 49) || (n >= 90 && n <= 99);
};

/** Whether the two-digit Gaza usage `code` is a legal class: 00-29 or 40-59. */
const gazaUsageOk = (code: string): boolean => {
  if (!twoDigits.test(code)) return false;
  const n = Number(code);
  return n <= 29 || (n >= 40 && n <= 59);
};

/**
 * Modern West Bank plate validator (D·DDDD·L). Quiet until the governorate is
 * filled, so incomplete entry does not flash red.
 */
export class PSWestBankModernValidator extends GatedPlateValidator {
  readonly gateGroup = 'governorate';

  static readonly invalidRegion = 'Region code must be one digit.';
  static readonly invalidSerial = 'Serial must be four digits.';
  static readonly illegalLetterIO = 'The letters I and O are never issued; H is followed by J.';
  static readonly reservedGazaLetter = 'P, Q, R, S and T were allocated to Gaza and never issued.';
  static readonly invalidGovernorate = 'Governorate letter must be one of A-N (I and O excluded).';

  judge(entry: PlateEntry): PlateValidation {
    return PSWestBankModernValidator.validateFields({ region: entry.group('region'), serial: entry.group('serial'), governorate: entry.group('governorate') });
  }

  static validateFields(o: { region: string; serial: string; governorate: string }): PlateValidation {
    const V = PSWestBankModernValidator;
    const g = o.governorate;
    if (!isDigitsOfLength(o.region, 1)) return invalid(V.invalidRegion);
    if (!isDigitsOfLength(o.serial, 4)) return invalid(V.invalidSerial);
    if (g === 'I' || g === 'O') return invalid(V.illegalLetterIO);
    if (g.length === 1 && 'PQRST'.includes(g)) return invalid(V.reservedGazaLetter);
    if (g.length !== 1 || !governorateLetters.includes(g)) return invalid(V.invalidGovernorate);
    return valid;
  }
}

/** Legacy West Bank plate validator (D·DDDD·DD). Quiet until the usage code is filled. */
export class PSWestBankLegacyValidator extends GatedPlateValidator {
  readonly gateGroup = 'usage';

  static readonly invalidDistrictCode = 'District code must be 1 or 3-9 (0 and 2 are never issued).';
  static readonly invalidSerial = 'Serial must be four digits.';
  static readonly invalidUsageCode = 'Usage code is not a legal class (see PSLegacyUsage.codes).';

  judge(entry: PlateEntry): PlateValidation {
    return PSWestBankLegacyValidator.validateFields({ district: entry.group('district'), serial: entry.group('serial'), usage: entry.group('usage') });
  }

  static validateFields(o: { district: string; serial: string; usage: string }): PlateValidation {
    const V = PSWestBankLegacyValidator;
    if (o.district.length !== 1 || !legacyDistricts.includes(o.district)) return invalid(V.invalidDistrictCode);
    if (!isDigitsOfLength(o.serial, 4)) return invalid(V.invalidSerial);
    if (!legacyUsageOk(o.usage)) return invalid(V.invalidUsageCode);
    return valid;
  }
}

/** Gaza plate validator (3·DDDD·DD). Quiet until the usage code is filled. */
export class PSGazaValidator extends GatedPlateValidator {
  readonly gateGroup = 'usage';

  static readonly gazaPrefixNotThree = 'A Gaza plate always begins with 3.';
  static readonly invalidSerial = 'Serial must be four digits.';
  static readonly invalidUsageCode = 'Usage code is not a legal Gaza class (00-29 or 40-59).';

  judge(entry: PlateEntry): PlateValidation {
    return PSGazaValidator.validateFields({ prefix: entry.group('prefix'), serial: entry.group('serial'), usage: entry.group('usage') });
  }

  static validateFields(o: { prefix: string; serial: string; usage: string }): PlateValidation {
    const V = PSGazaValidator;
    if (o.prefix !== '3') return invalid(V.gazaPrefixNotThree);
    if (!isDigitsOfLength(o.serial, 4)) return invalid(V.invalidSerial);
    if (!gazaUsageOk(o.usage)) return invalid(V.invalidUsageCode);
    return valid;
  }
}

import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

const refused = '012';
const notFound = 'COUNTRY NOT FOUND';
const missions = new Set('002 003 004 005 006 007 008 009 010 011 013 014 015 017 018 019 020 021 022 023 024 025 026 027 028 029 030 031 032 033 034 035 036 037 038 039 040 041 042 043 044 045 046 047 048 049 050 051 052 053 054 055 056 057 058 059 060 061 062 063 064 065 066 067 068 069 070 071 072 073 074 075 076 077 078 079 080 081 082 083 084 085 086 087 088 089 090 091 092 093 094 095 096 097 098 099 100 199 206'.split(' '));

/** Judges a Ukrainian plate field by field: every field must be filled once
 * the last one (`series`) is started. A diplomatic `mission` is checked
 * against the mission list and `012` is refused on this validator's own
 * account as well as through the spec's restriction. Advisory. */
export class UkraineValidator extends GatedPlateValidator {
  readonly gateGroup = 'series';

  override validate(entry: PlateEntry): PlateValidation {
    if (entry.group('mission') === refused) {
      return invalid(notFound);
    }
    return super.validate(entry);
  }

  judge(entry: PlateEntry): PlateValidation {
    for (const g of entry.spec.textGroups) {
      if (g.key === undefined) continue;
      if (entry.group(g.key) === '') {
        return invalid(`The ${g.key} is incomplete.`);
      }
    }
    const mission = entry.group('mission');
    if (mission !== '' && !missions.has(mission)) {
      return invalid(notFound);
    }
    return valid;
  }
}

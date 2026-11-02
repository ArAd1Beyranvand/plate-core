"""Port of palestine_plate/lib/src/palestine_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import (
    GatedPlateValidator, PlateEntry, PlateValidation, is_digits_of_length)

_GOVERNORATE_LETTERS = "ABCDEFGHJKLMN"
_LEGACY_DISTRICTS = "13456789"
_LEGACY_USAGE = frozenset(
    ["30", "31", "32"] + [str(n) for n in range(40, 50)] + [str(n) for n in range(90, 100)])
_GAZA_USAGE = frozenset(f"{n:02d}" for n in (*range(0, 30), *range(40, 60)))

_invalid = PlateValidation.invalid


class PSWestBankModernValidator(GatedPlateValidator):
    gate_group = 'governorate'

    INVALID_REGION = "Region code must be one digit."
    INVALID_SERIAL = "Serial must be four digits."
    ILLEGAL_LETTER_IO = "The letters I and O are never issued; H is followed by J."
    RESERVED_GAZA_LETTER = "P, Q, R, S and T were allocated to Gaza and never issued."
    INVALID_GOVERNORATE = "Governorate letter must be one of A-N (I and O excluded)."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        return self.validate_fields(region=entry.group("region"), serial=entry.group("serial"),
                                    governorate=entry.group("governorate"))

    @classmethod
    def validate_fields(cls, *, region: str, serial: str, governorate: str) -> PlateValidation:
        if not is_digits_of_length(region, 1):
            return _invalid(cls.INVALID_REGION)
        if not is_digits_of_length(serial, 4):
            return _invalid(cls.INVALID_SERIAL)
        if governorate in ("I", "O"):
            return _invalid(cls.ILLEGAL_LETTER_IO)
        if governorate in ("P", "Q", "R", "S", "T"):
            return _invalid(cls.RESERVED_GAZA_LETTER)
        if len(governorate) != 1 or governorate not in _GOVERNORATE_LETTERS:
            return _invalid(cls.INVALID_GOVERNORATE)
        return PlateValidation.valid()


class PSWestBankLegacyValidator(GatedPlateValidator):
    gate_group = 'usage'

    INVALID_DISTRICT_CODE = "District code must be 1 or 3-9 (0 and 2 are never issued)."
    INVALID_SERIAL = "Serial must be four digits."
    INVALID_USAGE_CODE = "Usage code is not a legal class (see PSLegacyUsage.codes)."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        return self.validate_fields(district=entry.group("district"), serial=entry.group("serial"),
                                    usage=entry.group("usage"))

    @classmethod
    def validate_fields(cls, *, district: str, serial: str, usage: str) -> PlateValidation:
        if len(district) != 1 or district not in _LEGACY_DISTRICTS:
            return _invalid(cls.INVALID_DISTRICT_CODE)
        if not is_digits_of_length(serial, 4):
            return _invalid(cls.INVALID_SERIAL)
        if usage not in _LEGACY_USAGE:
            return _invalid(cls.INVALID_USAGE_CODE)
        return PlateValidation.valid()


class PSGazaValidator(GatedPlateValidator):
    gate_group = 'usage'

    GAZA_PREFIX_NOT_THREE = "A Gaza plate always begins with 3."
    INVALID_SERIAL = "Serial must be four digits."
    INVALID_USAGE_CODE = "Usage code is not a legal Gaza class (00-29 or 40-59)."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        return self.validate_fields(prefix=entry.group("prefix"), serial=entry.group("serial"),
                                    usage=entry.group("usage"))

    @classmethod
    def validate_fields(cls, *, prefix: str, serial: str, usage: str) -> PlateValidation:
        if prefix != "3":
            return _invalid(cls.GAZA_PREFIX_NOT_THREE)
        if not is_digits_of_length(serial, 4):
            return _invalid(cls.INVALID_SERIAL)
        if usage not in _GAZA_USAGE:
            return _invalid(cls.INVALID_USAGE_CODE)
        return PlateValidation.valid()

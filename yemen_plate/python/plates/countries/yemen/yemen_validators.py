"""Port of yemen_plate/lib/src/common/yemen_validators.dart."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation, is_digits

_MIN_GOVERNORATE, _MAX_GOVERNORATE = 1, 22


class YemenUnifiedValidator(GatedPlateValidator):
    gate_group = 'sideCode'

    REASON_NUMBER_NOT_NUMERIC = 'The vehicle number is digits only.'
    REASON_NUMBER_LENGTH = 'The vehicle number is four to six digits.'
    REASON_SIDE_CODE_NOT_NUMERIC = 'The side code is digits only.'
    REASON_SIDE_CODE_LENGTH = 'The side code is two digits.'
    MIN_NUMBER_LENGTH = 4
    MAX_NUMBER_LENGTH = 6

    def judge(self, entry: PlateEntry) -> PlateValidation:
        return self.validate_fields(number=entry.group('number'), side_code=entry.group('sideCode'))

    @classmethod
    def validate_fields(cls, *, number: str, side_code: str) -> PlateValidation:
        if number and not is_digits(number):
            return PlateValidation.invalid(cls.REASON_NUMBER_NOT_NUMERIC)
        if not cls.MIN_NUMBER_LENGTH <= len(number) <= cls.MAX_NUMBER_LENGTH:
            return PlateValidation.invalid(cls.REASON_NUMBER_LENGTH)
        if not is_digits(side_code):
            return PlateValidation.invalid(cls.REASON_SIDE_CODE_NOT_NUMERIC)
        if len(side_code) != 2:
            return PlateValidation.invalid(cls.REASON_SIDE_CODE_LENGTH)
        return PlateValidation.valid()


class YemenNorthernValidator(GatedPlateValidator):
    gate_group = 'serial'

    REASON_GOVERNORATE_NOT_NUMERIC = 'The governorate code is digits only.'
    REASON_GOVERNORATE_LENGTH = 'The governorate code is one or two digits.'
    REASON_GOVERNORATE_RANGE = 'The governorate code is 1 to 22.'
    REASON_SERIAL_NOT_NUMERIC = 'The serial is digits only.'
    REASON_SERIAL_LENGTH = 'The serial is four to six digits.'
    REASON_SERIAL_LEADING_ZERO = 'The serial is not padded with leading zeros.'
    MIN_SERIAL_LENGTH = 4
    MAX_SERIAL_LENGTH = 6

    def judge(self, entry: PlateEntry) -> PlateValidation:
        return self.validate_fields(governorate=entry.group('governorate'), serial=entry.group('serial'))

    @classmethod
    def validate_fields(cls, *, governorate: str, serial: str) -> PlateValidation:
        if not governorate or len(governorate) > 2:
            return PlateValidation.invalid(cls.REASON_GOVERNORATE_LENGTH)
        if not is_digits(governorate):
            return PlateValidation.invalid(cls.REASON_GOVERNORATE_NOT_NUMERIC)
        if not _MIN_GOVERNORATE <= int(governorate) <= _MAX_GOVERNORATE:
            return PlateValidation.invalid(cls.REASON_GOVERNORATE_RANGE)
        if not cls.MIN_SERIAL_LENGTH <= len(serial) <= cls.MAX_SERIAL_LENGTH:
            return PlateValidation.invalid(cls.REASON_SERIAL_LENGTH)
        if not is_digits(serial):
            return PlateValidation.invalid(cls.REASON_SERIAL_NOT_NUMERIC)
        if serial.startswith('0'):
            return PlateValidation.invalid(cls.REASON_SERIAL_LEADING_ZERO)
        return PlateValidation.valid()


class YemenSouthernValidator(GatedPlateValidator):
    gate_group = 'serial'

    REASON_SERIAL_NOT_NUMERIC = 'The number is digits only.'
    REASON_SERIAL_LENGTH = 'The number is three to five digits.'
    MIN_SERIAL_LENGTH = 3
    MAX_SERIAL_LENGTH = 5

    def judge(self, entry: PlateEntry) -> PlateValidation:
        return self.validate_fields(serial=entry.group('serial'))

    @classmethod
    def validate_fields(cls, *, serial: str) -> PlateValidation:
        if not cls.MIN_SERIAL_LENGTH <= len(serial) <= cls.MAX_SERIAL_LENGTH:
            return PlateValidation.invalid(cls.REASON_SERIAL_LENGTH)
        if not is_digits(serial):
            return PlateValidation.invalid(cls.REASON_SERIAL_NOT_NUMERIC)
        return PlateValidation.valid()

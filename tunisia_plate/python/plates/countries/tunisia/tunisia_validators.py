"""Port of tunisia_plate/lib/src/tunisia_validators.dart."""
from __future__ import annotations

from dataclasses import dataclass

from plates.core.validators.plate_validator import (
    GatedPlateValidator, PlateEntry, PlateValidation, is_digits, is_digits_of_length)


class TunisiaValidator(GatedPlateValidator):
    gate_group = 'number'

    REASON_SERIES = 'The series is 1 to 999.'
    REASON_NUMBER = 'The registration is four digits.'
    REASON_ZERO = 'The registration is 0001 to 9999.'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        return self.validate_fields(series=entry.group('series'), number=entry.group('number'))

    @classmethod
    def validate_fields(cls, *, series: str, number: str) -> PlateValidation:
        if not series or len(series) > 3 or not is_digits(series) or series.startswith('0'):
            return PlateValidation.invalid(cls.REASON_SERIES)
        if not is_digits_of_length(number, 4):
            return PlateValidation.invalid(cls.REASON_NUMBER)
        if number == '0000':
            return PlateValidation.invalid(cls.REASON_ZERO)
        return PlateValidation.valid()


class TunisiaGovernmentValidator(GatedPlateValidator):
    gate_group = 'number'

    REASON_MINISTRY = 'The ministry code is two digits.'
    REASON_NUMBER = 'The vehicle number is one to six digits.'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if not is_digits_of_length(entry.group('ministry'), 2):
            return PlateValidation.invalid(self.REASON_MINISTRY)
        number = entry.group('number')
        if not is_digits(number) or len(number) > 6:
            return PlateValidation.invalid(self.REASON_NUMBER)
        return PlateValidation.valid()


@dataclass(frozen=True)
class TunisiaDiplomaticValidator(GatedPlateValidator):
    chief: bool = False
    gate_group = 'serial'

    REASON_DIGITS = 'Both numbers are two digits.'
    REASON_CHIEF = "A head of mission's plate ends 01."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        serial = entry.group('serial')
        if not is_digits_of_length(entry.group('country'), 2) or not is_digits_of_length(serial, 2):
            return PlateValidation.invalid(self.REASON_DIGITS)
        if self.chief and serial != '01':
            return PlateValidation.invalid(self.REASON_CHIEF)
        return PlateValidation.valid()


class TunisiaSerialValidator(GatedPlateValidator):
    gate_group = 'serial'

    REASON_SERIAL = 'The serial is five digits.'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if is_digits_of_length(entry.group('serial'), 5):
            return PlateValidation.valid()
        return PlateValidation.invalid(self.REASON_SERIAL)

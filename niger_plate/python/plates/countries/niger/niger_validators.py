"""Port of niger_plate/lib/src/niger_validators.dart."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation, is_digits_of_length

_REGIONS = "12345678"
_LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"


def _one_of(chars: str, value: str) -> bool:
    return len(value) == 1 and value in chars


class NigerValidator(GatedPlateValidator):
    gate_group = "serial"
    reason_region = "The region is a digit from 1 to 8."
    reason_series = "The series is one letter."
    reason_serial = "The serial is four digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        return self.validate_fields(entry.group("region"), entry.group("series"), entry.group("serial"))

    @classmethod
    def validate_fields(cls, region: str, series: str, serial: str) -> PlateValidation:
        if not _one_of(_REGIONS, region):
            return PlateValidation.invalid(cls.reason_region)
        if not _one_of(_LETTERS, series):
            return PlateValidation.invalid(cls.reason_series)
        if not is_digits_of_length(serial, 4):
            return PlateValidation.invalid(cls.reason_serial)
        return PlateValidation.valid()


class NigerStateValidator(GatedPlateValidator):
    gate_group = "serial"

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if not is_digits_of_length(entry.group("serial"), 5):
            return PlateValidation.invalid("The serial is five digits.")
        if not _one_of(_REGIONS, entry.group("area")):
            return PlateValidation.invalid(NigerValidator.reason_region)
        return PlateValidation.valid()


class NigerMilitaryValidator(GatedPlateValidator):
    gate_group = "serial"

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if is_digits_of_length(entry.group("serial"), 5):
            return PlateValidation.valid()
        return PlateValidation.invalid("The serial is five digits.")


class NigerDiplomaticValidator(GatedPlateValidator):
    gate_group = "code"

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if not is_digits_of_length(entry.group("code"), 3):
            return PlateValidation.invalid("The country code is three digits.")
        room = entry.group("room")
        if room and not is_digits_of_length(room, 1):
            return PlateValidation.invalid("The room is one digit.")
        return PlateValidation.valid()

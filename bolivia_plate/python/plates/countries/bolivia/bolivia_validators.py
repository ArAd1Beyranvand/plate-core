"""Port of bolivia_plate/lib/src/bolivia_validators.dart."""
from __future__ import annotations

import re

from plates.core.validators.plate_validator import (
    GatedPlateValidator, PlateEntry, PlateValidation, is_digits, is_digits_of_length)

_DEPARTMENTS = "CHBLONPST"


class BoliviaValidator(GatedPlateValidator):
    gate_group = "letters"
    reason_number = "The number is three or four digits."
    reason_letters = "The series is three letters."
    reason_department = "The department is one of C H B L O N P S T."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        return self.validate_fields(entry.group("number"), entry.group("letters"), entry.group("department"))

    @classmethod
    def validate_fields(cls, number: str, letters: str, department: str) -> PlateValidation:
        if len(number) not in (3, 4) or not is_digits(number):
            return PlateValidation.invalid(cls.reason_number)
        if re.fullmatch(r"[A-Z]{3}", letters) is None:
            return PlateValidation.invalid(cls.reason_letters)
        if len(department) != 1 or department not in _DEPARTMENTS:
            return PlateValidation.invalid(cls.reason_department)
        return PlateValidation.valid()


class BoliviaSpecialValidator(GatedPlateValidator):
    gate_group = "rank"
    reason_digits = "Both numbers are two digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        ok = is_digits_of_length(entry.group("country"), 2) and is_digits_of_length(entry.group("rank"), 2)
        return PlateValidation.valid() if ok else PlateValidation.invalid(self.reason_digits)


class BoliviaMercosurValidator(GatedPlateValidator):
    gate_group = "number"
    reason_letters = "The series is two letters."
    reason_number = "The number is five digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if re.fullmatch(r"[A-Z]{2}", entry.group("letters")) is None:
            return PlateValidation.invalid(self.reason_letters)
        if not is_digits_of_length(entry.group("number"), 5):
            return PlateValidation.invalid(self.reason_number)
        return PlateValidation.valid()

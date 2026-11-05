"""Port of bolivia_plate/lib/src/bolivia_validators.dart."""
from __future__ import annotations

import re

from plates.core.validators.plate_validator import GatedPlateValidator, PlateCheck, PlateEntry, PlateValidation, RuledPlateValidator, is_digits, is_digits_of_length

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


class BoliviaMercosurValidator(RuledPlateValidator):
    checks = (
        PlateCheck("letters", r"[A-Z]{2}", "The series is two letters."),
        PlateCheck("number", r"[0-9]{5}", "The number is five digits."),
    )

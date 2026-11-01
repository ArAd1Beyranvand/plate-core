"""Port of caribbean_plate/lib/src/bonaire/src/bonaire_validators.dart."""
from __future__ import annotations

import re
from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation, is_digits


class BonaireValidator(GatedPlateValidator):
    gate_group = "number"

    _prefix = re.compile(r"^[A-Z]{1,2}$")

    reason_prefix = "The prefix is one or two letters."
    reason_number = "The number is three to five digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if not self._prefix.fullmatch(entry.group("prefix")):
            return PlateValidation.invalid(self.reason_prefix)
        number = entry.group("number")
        if len(number) < 3 or len(number) > 5 or not is_digits(entry.group("number")):
            return PlateValidation.invalid(self.reason_number)
        return PlateValidation.valid()


@dataclass(frozen=True)
class BonaireIslandValidator(GatedPlateValidator):
    island: str
    min_digits: int = 1
    gate_group = "number"

    reason_number = "The number is up to four digits."

    def reason_island(self) -> str:
        return f"The prefix is {self.island}."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if entry.group("prefix") != self.island:
            return PlateValidation.invalid(self.reason_island())
        number = entry.group("number")
        if len(number) < self.min_digits or len(number) > 4 or not is_digits(number):
            return PlateValidation.invalid(self.reason_number)
        return PlateValidation.valid()

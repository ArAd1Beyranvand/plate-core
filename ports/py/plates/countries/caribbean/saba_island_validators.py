"""Port of caribbean_plate/lib/src/saba_island/src/saba_island_validators.dart."""
from __future__ import annotations

import re
from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


@dataclass(frozen=True)
class SabaIslandValidator(GatedPlateValidator):
    min_digits: int
    max_digits: int
    gate_group = "number"
    _prefix_re = re.compile(r"^[SRD]$")
    reason_prefix = "The prefix is S, R or D."

    def reason_number(self) -> str:
        if self.min_digits == self.max_digits:
            return f"The number is {self.max_digits} digits."
        return f"The number is {self.min_digits} to {self.max_digits} digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if not self._prefix_re.fullmatch(entry.group("prefix")):
            return PlateValidation.invalid(self.reason_prefix)
        number = entry.group("number")
        if len(number) < self.min_digits or len(number) > self.max_digits or not re.fullmatch(r"[0-9]+", number):
            return PlateValidation.invalid(self.reason_number())
        return PlateValidation.valid()

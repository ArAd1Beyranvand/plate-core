"""Port of antigua_and_barbuda_plate/lib/src/antigua_and_barbuda_validators.dart."""
from __future__ import annotations

import re
from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation, is_digits


@dataclass(frozen=True)
class AntiguaAndBarbudaValidator(GatedPlateValidator):
    max_digits: int = 4
    gate_group = "serial"
    reason_letter = "The class is one letter."
    _letter = re.compile(r"^[A-Z]$")

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if not self._letter.fullmatch(entry.group("letter")):
            return PlateValidation.invalid(self.reason_letter)
        serial = entry.group("serial")
        if not serial or len(serial) > self.max_digits or not is_digits(serial):
            return PlateValidation.invalid(f"The number is one to {self.max_digits} digits.")
        return PlateValidation.valid()

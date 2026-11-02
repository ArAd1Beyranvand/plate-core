"""Port of mali_plate/lib/src/mali_validators.dart."""
from __future__ import annotations

import re
from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


@dataclass(frozen=True)
class MaliValidator(GatedPlateValidator):
    gate_group = "suffix"
    reason_format = "Format is 2 letters, 4 digits, 2 letters."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        prefix, number, suffix = entry.group("prefix"), entry.group("number"), entry.group("suffix")
        if len(prefix) != 2 or len(number) != 4 or len(suffix) != 2:
            return PlateValidation.invalid(self.reason_format)
        return PlateValidation.valid()

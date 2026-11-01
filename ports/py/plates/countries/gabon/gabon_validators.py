"""Port of gabon_plate/lib/src/gabon_validators.dart."""
from __future__ import annotations

import re
from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class GabonValidator(GatedPlateValidator):
    gate_group = "number"
    _two_letters = re.compile(r"^[A-Z]{2}$")

    def judge(self, entry: PlateEntry) -> PlateValidation:
        series = entry.group("series")
        number = entry.group("number")
        suffix = entry.group("suffix")

        if not self._two_letters.match(series):
            return PlateValidation.invalid("The first group is 2 letters.")
        if not (number.isdigit() and len(number) == 3):
            return PlateValidation.invalid("The number is 3 digits.")
        if not self._two_letters.match(suffix):
            return PlateValidation.invalid("The last group is 2 letters.")
        return PlateValidation.valid()

"""Port of togo_plate/lib/src/togo_validators.dart."""
from __future__ import annotations

import re
from plates.core.validators.plate_validator import PlateEntry, PlateValidation


class TogoValidator:
    _digits4 = re.compile(r"[0-9]{4}")
    _letters2 = re.compile(r"[A-Z]{2}")

    def validate(self, entry: PlateEntry) -> PlateValidation:
        if entry.group("series") == "":
            return PlateValidation.valid()
        if not self._digits4.fullmatch(entry.group("number")):
            return PlateValidation.invalid("The number is 4 digits.")
        if not self._letters2.fullmatch(entry.group("series")):
            return PlateValidation.invalid("The series is 2 letters.")
        return PlateValidation.valid()

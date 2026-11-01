"""Port of angola_plate/lib/src/angola_validators.dart."""
from __future__ import annotations

import re

from plates.core.validators.plate_validator import (
    GatedPlateValidator, PlateEntry, PlateValidation, is_digits_of_length)

_PAIR = re.compile(r"[A-Z]{2}")


class AngolaValidator(GatedPlateValidator):
    """Judges an Angolan plate by its groups: `AA-##-##-AA`."""

    gate_group = "suffix"

    REASON_REGION = "The region is two letters."
    REASON_DIGITS = "The number is two pairs of digits."
    REASON_SUFFIX = "The series is two letters."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        region = entry.group("region")
        if not _PAIR.fullmatch(region):
            return PlateValidation.invalid(self.REASON_REGION)

        first = entry.group("first")
        second = entry.group("second")
        if not is_digits_of_length(first, 2) or not is_digits_of_length(second, 2):
            return PlateValidation.invalid(self.REASON_DIGITS)

        suffix = entry.group("suffix")
        if not _PAIR.fullmatch(suffix):
            return PlateValidation.invalid(self.REASON_SUFFIX)

        return PlateValidation.valid()

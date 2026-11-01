"""Port of andorra_plate/lib/src/andorra_validators.dart."""
from __future__ import annotations

import re

from plates.core.validators.plate_validator import (
    GatedPlateValidator, PlateEntry, PlateValidation, is_digits_of_length)

_MONTH = re.compile(r"(I{1,3}|IV|IX|VI{0,3}|XI{0,2})")
_LETTER = re.compile(r"[A-Z]")


class AndorraValidator(GatedPlateValidator):
    """Judges an Andorran plate by its groups: `L 3705`, or `MT`, four digits, a Roman month and a year."""

    gate_group = "digits"

    REASON_STANDARD = "A plate is one letter and four digits."
    REASON_TEMPORARY = "A temporary plate is four digits, a month (I to XII) and a year."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        digits, month, year = entry.group("digits"), entry.group("month"), entry.group("year")
        if month or year:
            ok = is_digits_of_length(digits, 4) and _MONTH.fullmatch(month) and is_digits_of_length(year, 2)
            return PlateValidation.valid() if ok else PlateValidation.invalid(self.REASON_TEMPORARY)
        ok = is_digits_of_length(digits, 4) and _LETTER.fullmatch(entry.group("letter"))
        return PlateValidation.valid() if ok else PlateValidation.invalid(self.REASON_STANDARD)

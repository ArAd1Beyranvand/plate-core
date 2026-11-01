"""Port of norway_plate/lib/src/norway_validators.dart."""
from __future__ import annotations

import re
from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation, is_digits


@dataclass(frozen=True)
class NorwayValidator(GatedPlateValidator):
    gate_group = "number"

    def judge(self, entry: PlateEntry) -> PlateValidation:
        code = entry.group("code")
        if code:
            if code != "CD":
                return PlateValidation.invalid("The prefix is CD.")
            if not is_digits(entry.group("embassy")) or len(entry.group("embassy")) != 2:
                return PlateValidation.invalid("The mission code is two digits.")
            if not is_digits(entry.group("number")) or len(entry.group("number")) != 3:
                return PlateValidation.invalid("The sequence is three digits.")
            return PlateValidation.valid()
        if not re.fullmatch(r"[ABCDEFHJKLNPRSTUVWXYZ]{2}", entry.group("letters")):
            return PlateValidation.invalid("The prefix is two letters (no G, I, M, O, Q).")
        number = entry.group("number")
        if not is_digits(number) or len(number) < 4 or len(number) > 5:
            return PlateValidation.invalid("The number is four or five digits.")
        return PlateValidation.valid()

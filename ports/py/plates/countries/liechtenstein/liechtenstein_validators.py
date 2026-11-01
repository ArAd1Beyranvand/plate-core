"""Port of liechtenstein_plate/lib/src/liechtenstein_validators.dart."""
from __future__ import annotations

import re
from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation, is_digits


@dataclass(frozen=True)
class LiechtensteinValidator(GatedPlateValidator):
    ranges: tuple[tuple[int, int], ...]
    reason: str
    gate_group = "serial"

    def judge(self, entry: PlateEntry) -> PlateValidation:
        serial, month = entry.group("serial"), entry.group("month")
        ok = (is_digits(serial) and not serial.startswith("0")
              and any(lo <= int(serial) <= hi for lo, hi in self.ranges))
        month_ok = not month or (re.fullmatch(r"[+-]?[0-9]+", month) is not None and 1 <= int(month) <= 12)
        return PlateValidation.valid() if ok and month_ok else PlateValidation.invalid(self.reason)

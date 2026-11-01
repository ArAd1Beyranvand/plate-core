"""Port of caribbean_plate/lib/src/anguilla/src/anguilla_validators.dart."""
from __future__ import annotations

import re
from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class AnguillaValidator(GatedPlateValidator):
    gate_group = "serial"
    max_digits = 4
    reason_type = "The plate starts with a type letter."
    reason_serial = "The serial is one to four digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        return self.validate_fields(
            type=entry.group("type"),
            serial=entry.group("serial"),
        )

    @staticmethod
    def validate_fields(type: str, serial: str) -> PlateValidation:
        if not re.fullmatch(r"[A-Z]", type):
            return PlateValidation.invalid(AnguillaValidator.reason_type)
        if not re.fullmatch(r"[0-9]+", serial) or len(serial) > AnguillaValidator.max_digits:
            return PlateValidation.invalid(AnguillaValidator.reason_serial)
        return PlateValidation.valid()

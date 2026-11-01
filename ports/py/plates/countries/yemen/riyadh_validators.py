"""Port of yemen_plate/lib/src/riyadh/riyadh_validators.dart."""
from __future__ import annotations

import re
from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class RiyadhValidator(GatedPlateValidator):
    gate_group = "serial"
    reason_letters = "The register is three letters."
    reason_serial = "The number is one to four digits."
    _letters = re.compile(r"^[ABJDRSXTEGKLZNHUV]{3}$")

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if not self._letters.match(entry.group("letters")):
            return PlateValidation.invalid(self.reason_letters)
        serial = entry.group("serial")
        if not serial.isdigit() or len(serial) > 4:
            return PlateValidation.invalid(self.reason_serial)
        return PlateValidation.valid()

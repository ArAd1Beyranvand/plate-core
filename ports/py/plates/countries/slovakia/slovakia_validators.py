"""Port of slovakia_plate/lib/src/slovakia_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class SlovakiaValidator(GatedPlateValidator):
    gate_group = 'b'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

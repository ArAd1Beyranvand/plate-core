"""Port of south_sudan_plate/lib/src/south_sudan_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class SouthSudanValidator(GatedPlateValidator):
    gate_group = 'letters'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

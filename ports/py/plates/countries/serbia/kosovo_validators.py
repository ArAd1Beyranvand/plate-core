"""Port of serbia_plate/lib/src/kosovo/src/kosovo_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class KosovoValidator(GatedPlateValidator):
    gate_group = 'series'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

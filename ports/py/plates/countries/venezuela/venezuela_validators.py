"""Port of venezuela_plate/lib/src/venezuela_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class VenezuelaValidator(GatedPlateValidator):
    gate_group = 'state'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

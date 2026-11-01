"""Port of china_plate/lib/src/hong_kong/src/hong_kong_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class HongKongValidator(GatedPlateValidator):
    gate_group = 'digits'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

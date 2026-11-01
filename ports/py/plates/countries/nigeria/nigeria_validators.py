"""Port of nigeria_plate/lib/src/nigeria_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class NigeriaValidator(GatedPlateValidator):
    gate_group = 'suffix'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

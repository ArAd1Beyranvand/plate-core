"""Port of fiji_plate/lib/src/fiji_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class FijiValidator(GatedPlateValidator):
    gate_group = 'serial'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

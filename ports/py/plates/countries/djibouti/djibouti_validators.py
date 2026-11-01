"""Port of djibouti_plate/lib/src/djibouti_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class DjiboutiValidator(GatedPlateValidator):
    gate_group = 'code'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

"""Port of netherlands_plate/lib/src/netherlands_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class NetherlandsValidator(GatedPlateValidator):
    gate_group = 'a'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

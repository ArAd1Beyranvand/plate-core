"""Port of mauritania_plate/lib/src/mauritania_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class MauritaniaPlateValidator(GatedPlateValidator):
    gate_group = 'region'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

"""Port of equatorial_guinea_plate/lib/src/equatorial_guinea_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class EquatorialGuineaValidator(GatedPlateValidator):
    gate_group = 'series'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

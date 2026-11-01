"""Port of papua_new_guinea_plate/lib/src/papua_new_guinea_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


@dataclass(frozen=True)
class PapuaNewGuineaValidator(GatedPlateValidator):
    lead_min: int
    lead_max: int
    number_min: int
    number_max: int
    lead_starts_with: object
    gate_group = 'number'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

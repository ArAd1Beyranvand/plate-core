"""Port of egypt_plate/lib/src/egypt_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


@dataclass(frozen=True)
class EgyptValidator(GatedPlateValidator):
    lengths: tuple
    gate_group = 'digits'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

"""Port of switzerland_plate/lib/src/switzerland_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


@dataclass(frozen=True)
class SwitzerlandValidator(GatedPlateValidator):
    military: bool
    gate_group = 'number'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class SwitzerlandDiplomaticValidator(GatedPlateValidator):
    gate_group = 'code'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

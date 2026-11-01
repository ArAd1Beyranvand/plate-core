"""Port of italy_plate/lib/src/italy_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class ItalyValidator(GatedPlateValidator):
    gate_group = 'number'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


@dataclass(frozen=True)
class ItalyDiplomaticValidator(GatedPlateValidator):
    digits: int
    consular: bool
    gate_group = 'number'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

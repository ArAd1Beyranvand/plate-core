"""Port of bhutan_plate/lib/src/bhutan_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


@dataclass(frozen=True)
class BhutanValidator(GatedPlateValidator):
    types: tuple
    gate_group = 'type'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class BhutanDiplomaticValidator(GatedPlateValidator):
    gate_group = 'country'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

"""Port of polynesia_plate/lib/src/norfolk_island/src/norfolk_island_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class NorfolkIslandValidator(GatedPlateValidator):
    gate_group = 'block'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

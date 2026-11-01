"""Port of republic_of_the_congo_plate/lib/src/republic_of_the_congo_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class RepublicOfTheCongoValidator(GatedPlateValidator):
    gate_group = 'area'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

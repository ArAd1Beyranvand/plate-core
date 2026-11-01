"""Port of democratic_republic_of_the_congo_plate/lib/src/democratic_republic_of_the_congo_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class DemocraticRepublicOfTheCongoValidator(GatedPlateValidator):
    gate_group = 'province'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

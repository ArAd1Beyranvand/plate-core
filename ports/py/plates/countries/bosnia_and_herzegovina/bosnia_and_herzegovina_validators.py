"""Port of bosnia_and_herzegovina_plate/lib/src/bosnia_and_herzegovina_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class BosniaAndHerzegovinaValidator(GatedPlateValidator):
    gate_group = 'digits'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

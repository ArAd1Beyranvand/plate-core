"""Port of brunei_plate/lib/src/brunei_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class BruneiValidator(GatedPlateValidator):
    gate_group = 'number'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class BruneiDiplomaticValidator(GatedPlateValidator):
    gate_group = 'mission'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

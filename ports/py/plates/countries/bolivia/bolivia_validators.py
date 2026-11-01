"""Port of bolivia_plate/lib/src/bolivia_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class BoliviaValidator(GatedPlateValidator):
    gate_group = 'letters'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class BoliviaSpecialValidator(GatedPlateValidator):
    gate_group = 'rank'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class BoliviaMercosurValidator(GatedPlateValidator):
    gate_group = 'number'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

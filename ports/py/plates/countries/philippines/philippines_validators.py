"""Port of philippines_plate/lib/src/philippines_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


@dataclass(frozen=True)
class PhilippinesValidator(GatedPlateValidator):
    government: bool
    gate_group = 'number'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class PhilippinesMotorcycleValidator(GatedPlateValidator):
    gate_group = 'serial'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class PhilippinesDiplomaticValidator(GatedPlateValidator):
    gate_group = 'mission'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

"""Port of iranshahr_plate/lib/src/uzbekistan/uzbekistan_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class UzbekistanValidator(GatedPlateValidator):
    gate_group = 'region'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class UzbekistanDiplomaticValidator(GatedPlateValidator):
    gate_group = 'mission'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class UzbekistanUnitedNationsValidator(GatedPlateValidator):
    gate_group = 'serial'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

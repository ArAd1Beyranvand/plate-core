"""Port of bulgaria_plate/lib/src/bulgaria_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class BulgariaValidator(GatedPlateValidator):
    gate_group = 'series'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class BulgariaServiceValidator(GatedPlateValidator):
    gate_group = 'second'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class BulgariaStampedValidator(GatedPlateValidator):
    gate_group = 'year'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

"""Port of mozambique_plate/lib/src/mozambique_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class MozambiqueValidator(GatedPlateValidator):
    gate_group = 'number'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class MozambiqueLegacyValidator(GatedPlateValidator):
    gate_group = 'first'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

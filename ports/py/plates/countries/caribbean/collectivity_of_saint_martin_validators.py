"""Port of caribbean_plate/lib/src/collectivity_of_saint_martin/src/collectivity_of_saint_martin_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class CollectivityOfSaintMartinValidator(GatedPlateValidator):
    gate_group = 'letters'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

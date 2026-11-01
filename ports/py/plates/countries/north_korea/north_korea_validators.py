"""Port of north_korea_plate/lib/src/north_korea_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


@dataclass(frozen=True)
class KPValidator(GatedPlateValidator):
    gate_group: str

    gate_group = ""  # computed in Dart: port the gateGroup getter

    def validate(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

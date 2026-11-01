"""Port of mexico_plate/lib/src/mexico_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


@dataclass(frozen=True)
class MexicoValidator(GatedPlateValidator):
    format: str

    gate_group = ""  # computed in Dart: port the gateGroup getter

    def validate(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

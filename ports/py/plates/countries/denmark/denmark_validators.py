"""Port of denmark_plate/lib/src/denmark_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


@dataclass(frozen=True)
class DenmarkValidator(GatedPlateValidator):
    year_digits: int
    mid_digits: int
    number_digits: int
    allowed_letters: object
    gate_group = 'number'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class DenmarkVanityValidator(GatedPlateValidator):
    gate_group = 'text'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

"""Port of iranshahr_plate/lib/src/turkey/turkey_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from dataclasses import dataclass

from plates.core.validators.plate_validator import PlateEntry, PlateValidation


@dataclass(frozen=True)
class TurkeyPlateValidator:
    limit_six: bool

    def validate(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

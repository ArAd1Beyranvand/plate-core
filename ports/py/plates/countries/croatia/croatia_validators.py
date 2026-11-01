"""Port of croatia_plate/lib/src/croatia_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import PlateEntry, PlateValidation


class CroatiaValidator:
    def validate(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

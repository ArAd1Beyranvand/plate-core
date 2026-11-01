"""Port of portugal_plate/lib/src/portugal_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import PlateEntry, PlateValidation


class PortugalValidator:
    def validate(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

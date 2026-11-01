"""Port of india_plate/lib/src/india_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import PlateEntry, PlateValidation


class IndiaValidator:
    def validate(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

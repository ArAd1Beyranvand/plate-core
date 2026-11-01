"""Port of lithuania_plate/lib/src/lithuania_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import PlateEntry, PlateValidation


class LithuaniaValidator:
    def validate(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

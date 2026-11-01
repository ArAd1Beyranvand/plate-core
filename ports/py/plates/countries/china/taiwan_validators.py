"""Port of china_plate/lib/src/taiwan/src/taiwan_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class TaiwanValidator(GatedPlateValidator):
    gate_group = 'digits'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


@dataclass(frozen=True)
class TaiwanProtocolValidator(GatedPlateValidator):
    min_digits: int
    max_digits: int
    gate_group = 'digits'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

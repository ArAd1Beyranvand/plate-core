"""Port of iranshahr_plate/lib/src/tajikistan/tajikistan_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


@dataclass(frozen=True)
class TajikistanPlateValidator(GatedPlateValidator):
    serial_length: int
    letter_count: int
    check_region: bool
    gate: str
    gate_group = 'serial'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class TajikistanForeignPlateValidator(GatedPlateValidator):
    gate_group = 'serial'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class TajikistanDiplomaticPlateValidator(GatedPlateValidator):
    gate_group = 'tail'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

"""Port of iranshahr_plate/lib/src/armenia/armenia_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


@dataclass(frozen=True)
class ArmeniaPlateValidator(GatedPlateValidator):
    issued_year: object
    issued_month: int
    gate_group = 'serial'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class ArmeniaPublicPlateValidator(GatedPlateValidator):
    gate_group = 'tail'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class ArmeniaTrailerPlateValidator(GatedPlateValidator):
    gate_group = 'tail'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class ArmeniaBusPlateValidator(GatedPlateValidator):
    gate_group = 'class'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class ArmeniaDiplomaticPlateValidator(GatedPlateValidator):
    gate_group = 'serial'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class ArmeniaMilitaryPlateValidator(GatedPlateValidator):
    gate_group = 'class'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


@dataclass(frozen=True)
class ArmeniaSerialPlateValidator(GatedPlateValidator):
    length: int
    gate_group = 'serial'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

"""Port of romania_plate/lib/src/romania_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class RomaniaValidator(GatedPlateValidator):
    gate_group = 'letters'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class RomaniaTemporaryValidator(GatedPlateValidator):
    gate_group = 'number'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class RomaniaTestValidator(GatedPlateValidator):
    gate_group = 'number'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class RomaniaDiplomaticValidator(GatedPlateValidator):
    gate_group = 'rank'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

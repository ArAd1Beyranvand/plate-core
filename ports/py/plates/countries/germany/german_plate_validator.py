"""Port of germany_plate/lib/src/german_plate_validator.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class GermanPlateValidator(GatedPlateValidator):
    gate_group = 'letters'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class GermanSerialPlateValidator(GatedPlateValidator):
    gate_group = 'serial'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class GermanDatedPlateValidator(GatedPlateValidator):
    gate_group = 'expiryDay'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class GermanBundeswehrValidator(GatedPlateValidator):
    gate_group = 'serialTail'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

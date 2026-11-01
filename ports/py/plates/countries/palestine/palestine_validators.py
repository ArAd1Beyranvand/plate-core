"""Port of palestine_plate/lib/src/palestine_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class PSWestBankModernValidator(GatedPlateValidator):
    gate_group = 'governorate'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class PSWestBankLegacyValidator(GatedPlateValidator):
    gate_group = 'usage'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")


class PSGazaValidator(GatedPlateValidator):
    gate_group = 'usage'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError("not ported")

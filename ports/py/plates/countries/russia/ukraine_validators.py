"""Port of russia_plate/lib/src/ukraine/src/ukraine_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation
from plates.countries.russia.ukraine_missions import UkraineMissions


class UkraineValidator(GatedPlateValidator):
    gate_group = "series"

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if UkraineMissions.is_refused(entry.group("mission")):
            return PlateValidation.invalid(UkraineMissions.not_found)
        for group in entry.spec.text_groups:
            key = group.key
            if key is None:
                continue
            if entry.group(key).strip() == "":
                return PlateValidation.invalid(f"The {key} is incomplete.")
        mission = entry.group("mission")
        if mission.strip() != "" and UkraineMissions.name(mission) is None:
            return PlateValidation.invalid(UkraineMissions.not_found)
        return PlateValidation.valid()

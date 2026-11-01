"""Port of sahara_plate/lib/src/sahrawi_arab_democratic_republic_validators.dart."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation, is_digits


class SahrawiArabDemocraticRepublicValidator(GatedPlateValidator):
    gate_group = "serial"
    reason_civil = "A plate is SH or GSH, two digits and five digits."
    reason_army = "An army plate is nine digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        serial = entry.group("serial")
        if not entry.spec.indices_of_group("prefix"):
            return PlateValidation.valid() if len(serial) == 9 and is_digits(serial) else PlateValidation.invalid(self.reason_army)
        prefix = entry.group("prefix")
        code = entry.group("code")
        return (prefix in ("SH", "GSH") and len(code) == 2 and is_digits(code) and len(serial) == 5 and is_digits(serial)) and PlateValidation.valid() or PlateValidation.invalid(self.reason_civil)

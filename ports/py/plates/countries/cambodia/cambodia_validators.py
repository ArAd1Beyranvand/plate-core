"""Port of cambodia_plate/lib/src/cambodia_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation, is_digits


class CambodiaValidator(GatedPlateValidator):
    gate_group = "serial"

    reason_class = "The first number is not one of the article's vehicle classes."
    reason_letters = "The register is one or two letters."
    reason_serial = "The number is four digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if entry.group("class") not in {"1", "2", "3", "4", "5", "7", "9"}:
            return PlateValidation.invalid(self.reason_class)
        if entry.spec.indices_of_group("letters"):
            letters = len(entry.group("letters"))
            if letters < 1 or letters > 2:
                return PlateValidation.invalid(self.reason_letters)
        if not is_digits(entry.group("serial")) or len(entry.group("serial")) != 4:
            return PlateValidation.invalid(self.reason_serial)
        return PlateValidation.valid()


class CambodiaStackedValidator(GatedPlateValidator):
    gate_group = "serial"

    reason_prefix = "The prefix is CD or ONG."
    reason_code = "The code is two or three digits."
    reason_serial = "The number is three digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if entry.spec.indices_of_group("prefix"):
            if entry.group("prefix") not in {"CD", "ONG"}:
                return PlateValidation.invalid(self.reason_prefix)
        for key in ("mission", "org", "code"):
            if entry.spec.indices_of_group(key):
                length = 3 if key == "org" else 2
                if not is_digits(entry.group(key)) or len(entry.group(key)) != length:
                    return PlateValidation.invalid(self.reason_code)
        if not is_digits(entry.group("serial")) or len(entry.group("serial")) != 3:
            return PlateValidation.invalid(self.reason_serial)
        return PlateValidation.valid()

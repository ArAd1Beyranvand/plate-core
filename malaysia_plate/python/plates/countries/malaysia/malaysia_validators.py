"""Port of malaysia_plate/lib/src/malaysia_validators.dart."""
from __future__ import annotations

import re
from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


class MalaysiaValidator(GatedPlateValidator):
    gate_group = "number"

    reason_prefix_missing = "A plate starts with letters."
    reason_no_io = "I and O are not issued on Malaysian plates."
    reason_number = "The number is 1 to 9999."
    reason_leading_zero = "The number has no leading zero."
    reason_sabah_suffix = "A Sabah suffix is never Q or S."
    _not_issued = re.compile(r"[IO]")

    def judge(self, entry: PlateEntry) -> PlateValidation:
        return self.validate_fields(
            prefix=entry.group("prefix"),
            number=entry.group("number"),
            suffix=entry.group("suffix"),
        )

    @staticmethod
    def validate_fields(
        prefix: str,
        number: str,
        suffix: str = "",
    ) -> PlateValidation:
        if not prefix:
            return PlateValidation.invalid(MalaysiaValidator.reason_prefix_missing)
        if MalaysiaValidator._not_issued.search(prefix + suffix):
            return PlateValidation.invalid(MalaysiaValidator.reason_no_io)
        if not number or len(number) > 4 or not re.fullmatch(r"[0-9]+", number):
            return PlateValidation.invalid(MalaysiaValidator.reason_number)
        if number.startswith("0"):
            return PlateValidation.invalid(MalaysiaValidator.reason_leading_zero)
        if prefix.startswith("S") and suffix in ("Q", "S"):
            return PlateValidation.invalid(MalaysiaValidator.reason_sabah_suffix)
        return PlateValidation.valid()


class MalaysiaDiplomaticValidator(GatedPlateValidator):
    gate_group = "mission"

    reason_digits = "Both numbers are two digits."
    reason_mission = "The code is DC, CC, UN or PA."

    _missions = {"DC", "CC", "UN", "PA"}

    def judge(self, entry: PlateEntry) -> PlateValidation:
        country = entry.group("country")
        serial = entry.group("serial")
        if (
            len(country) != 2
            or len(serial) != 2
            or not re.fullmatch(r"[0-9]+", country)
            or not re.fullmatch(r"[0-9]+", serial)
        ):
            return PlateValidation.invalid(MalaysiaDiplomaticValidator.reason_digits)
        if entry.group("mission") not in MalaysiaDiplomaticValidator._missions:
            return PlateValidation.invalid(MalaysiaDiplomaticValidator.reason_mission)
        return PlateValidation.valid()

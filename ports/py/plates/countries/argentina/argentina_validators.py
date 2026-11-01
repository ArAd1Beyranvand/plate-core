"""Port of argentina_plate/lib/src/argentina_validators.dart."""
from __future__ import annotations

import re
from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation


@dataclass(frozen=True)
class ArgentinaStandardValidator(GatedPlateValidator):
    gate_group = "series"
    reason_series = "The series is two letters."
    reason_number = "The number is three digits."
    reason_suffix = "The suffix is two letters."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if not re.fullmatch(r"[A-Z]{2}", entry.group("series")):
            return PlateValidation.invalid(self.reason_series)
        if not re.fullmatch(r"[0-9]{3}", entry.group("number")):
            return PlateValidation.invalid(self.reason_number)
        if not re.fullmatch(r"[A-Z]{2}", entry.group("suffix")):
            return PlateValidation.invalid(self.reason_suffix)
        return PlateValidation.valid()


@dataclass(frozen=True)
class ArgentinaLegacyValidator(GatedPlateValidator):
    gate_group = "series"
    reason_series = "The series is three letters."
    reason_number = "The number is three digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if not re.fullmatch(r"[A-Z]{3}", entry.group("series")):
            return PlateValidation.invalid(self.reason_series)
        if not re.fullmatch(r"[0-9]{3}", entry.group("number")):
            return PlateValidation.invalid(self.reason_number)
        return PlateValidation.valid()


@dataclass(frozen=True)
class ArgentinaTrailerValidator(GatedPlateValidator):
    gate_group = "trailer"
    reason_trailer = "The trailer number is three digits."
    reason_series = "The mover's series is three letters."
    reason_number = "The mover's number is three digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if not re.fullmatch(r"[0-9]{3}", entry.group("trailer")):
            return PlateValidation.invalid(self.reason_trailer)
        if not re.fullmatch(r"[A-Z]{3}", entry.group("series")):
            return PlateValidation.invalid(self.reason_series)
        if not re.fullmatch(r"[0-9]{3}", entry.group("number")):
            return PlateValidation.invalid(self.reason_number)
        return PlateValidation.valid()


@dataclass(frozen=True)
class ArgentinaMissionValidator(GatedPlateValidator):
    gate_group = "prefix"
    reason_number = "The number is three digits."
    reason_suffix = "The suffix is three letters."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if entry.group("prefix") not in "DCMIA":
            return PlateValidation.invalid("The category is D, C, M, I or A.")
        if not re.fullmatch(r"[0-9]{3}", entry.group("number")):
            return PlateValidation.invalid(self.reason_number)
        if not re.fullmatch(r"[A-Z]{3}", entry.group("suffix")):
            return PlateValidation.invalid(self.reason_suffix)
        return PlateValidation.valid()


@dataclass(frozen=True)
class ArgentinaMission1985Validator(GatedPlateValidator):
    gate_group = "prefix"
    reason_number = "The number is four digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if entry.group("prefix") not in "CDCCMEOIPA":
            return PlateValidation.invalid("The category is CD, CC, ME, OI or PA.")
        if not re.fullmatch(r"[0-9]{4}", entry.group("number")):
            return PlateValidation.invalid(self.reason_number)
        return PlateValidation.valid()

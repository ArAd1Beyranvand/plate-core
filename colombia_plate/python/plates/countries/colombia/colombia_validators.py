"""Port of colombia_plate/lib/src/colombia_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

import re
from dataclasses import dataclass
from typing import NamedTuple

from plates.core.validators.plate_validator import (
    GatedPlateValidator, PlateEntry, PlateValidation, is_digits_of_length)


class ColombiaSeries(NamedTuple):
    english: str
    letters: int = 3
    digits: int = 3
    digits_first: bool = False
    fixed: str = ""


SERIES = {
    "private": ColombiaSeries("Private"),
    "commercial": ColombiaSeries("Public service"),
    "official": ColombiaSeries("Official", fixed="O"),
    "antique": ColombiaSeries("Antique car"),
    "mototaxi": ColombiaSeries("Auto rickshaw", digits_first=True),
    "trailer": ColombiaSeries("Trailer", 1, 5, fixed="R"),
    "tank": ColombiaSeries("Tank truck", 1, 4, fixed="T"),
    "cc": ColombiaSeries("Consular corps", 2, 4, fixed="CC"),
    "oi": ColombiaSeries("International organization", 2, 4, fixed="OI"),
    "at": ColombiaSeries("Non-diplomatic staff", 2, 4, fixed="AT"),
}

_TYPE_LETTER = re.compile(r"[A-Z]")
_COUNTRY_INITIALS = re.compile(r"[A-Z]{2}")


@dataclass(frozen=True)
class ColombiaValidator(GatedPlateValidator):
    series: str = "private"

    @property
    def gate_group(self) -> str:
        return "letters" if SERIES[self.series].digits_first else "number"

    def judge(self, entry: PlateEntry) -> PlateValidation:
        return self.validate_fields(self.series, letters=entry.group("letters"), number=entry.group("number"))

    @staticmethod
    def validate_fields(series: str, *, letters: str, number: str) -> PlateValidation:
        s = SERIES[series]
        if not re.fullmatch(f"[A-Z]{{{s.letters}}}", letters):
            return PlateValidation.invalid(f"The series is {s.letters} letter{'' if s.letters == 1 else 's'}.")
        if not letters.startswith(s.fixed):
            return PlateValidation.invalid(f"{s.english} plates start with {s.fixed}.")
        if not is_digits_of_length(number, s.digits):
            return PlateValidation.invalid(f"The number is {s.digits} digits.")
        return PlateValidation.valid()


class ColombiaPoliceValidator(GatedPlateValidator):
    gate_group = 'number'

    REASON = "The number is two digits and four digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        ok = is_digits_of_length(entry.group("unit"), 2) and is_digits_of_length(entry.group("number"), 4)
        return PlateValidation.valid() if ok else PlateValidation.invalid(self.REASON)


class ColombiaDiplomaticValidator(GatedPlateValidator):
    gate_group = 'number'

    REASON_LETTERS = "A type letter and two country initials."
    REASON_NUMBER = "The number is three digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if (not _TYPE_LETTER.fullmatch(entry.group("type"))
                or not _COUNTRY_INITIALS.fullmatch(entry.group("country"))):
            return PlateValidation.invalid(self.REASON_LETTERS)
        if not is_digits_of_length(entry.group("number"), 3):
            return PlateValidation.invalid(self.REASON_NUMBER)
        return PlateValidation.valid()

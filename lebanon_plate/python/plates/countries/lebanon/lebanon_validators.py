"""Port of lebanon_plate/lib/src/lebanon_validators.dart."""
from __future__ import annotations

import re

from plates.core.validators.plate_validator import (
    GatedPlateValidator, PlateEntry, PlateValidation, is_digits, restriction_verdict)


_LETTERS = frozenset("A B Y G N O S T K Z J R M C D P MP".split())


class LebanonValidator(GatedPlateValidator):
    gate_group = "serial"

    REASON_LETTER_MISSING = "A plate starts with a letter."
    REASON_LETTER_UNKNOWN = "That is not a Lebanese plate letter."
    REASON_SERIAL_NOT_NUMERIC = "The number is digits only."
    REASON_SERIAL_LENGTH = "The number is one to six digits."
    REASON_PARLIAMENT_RANGE = "A parliament plate is numbered 1 to 128."

    MIN_SERIAL_LENGTH = 1
    MAX_SERIAL_LENGTH = 6
    MAX_PARLIAMENT_NUMBER = 128

    def judge(self, entry: PlateEntry) -> PlateValidation:
        return self.validate_fields(entry.group("letter"), entry.group("serial"))

    @staticmethod
    def validate_fields(letter: str, serial: str) -> PlateValidation:
        cls = LebanonValidator
        if not letter:
            return PlateValidation.invalid(cls.REASON_LETTER_MISSING)
        code = letter.upper()
        if code not in _LETTERS:
            return PlateValidation.invalid(cls.REASON_LETTER_UNKNOWN)
        if not cls.MIN_SERIAL_LENGTH <= len(serial) <= cls.MAX_SERIAL_LENGTH:
            return PlateValidation.invalid(cls.REASON_SERIAL_LENGTH)
        if not is_digits(serial):
            return PlateValidation.invalid(cls.REASON_SERIAL_NOT_NUMERIC)
        if code == "MP" and not 1 <= int(serial) <= cls.MAX_PARLIAMENT_NUMBER:
            return PlateValidation.invalid(cls.REASON_PARLIAMENT_RANGE)
        return PlateValidation.valid()

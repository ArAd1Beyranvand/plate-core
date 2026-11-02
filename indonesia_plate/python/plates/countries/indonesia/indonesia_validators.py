"""Port of indonesia_plate/lib/src/indonesia_validators.dart."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation, is_digits

INDONESIA_AREA_CODES = frozenset((
    "BL", "BB", "BK", "BA", "BM", "BP", "BH", "BD", "BG", "BN", "BE", "A", "B", "F", "T", "E",
    "D", "Z", "R", "G", "H", "K", "AA", "AD", "AB", "AE", "AG", "S", "W", "L", "M", "N", "P",
    "KB", "KH", "DA", "KT", "KU", "DL", "DB", "DM", "DN", "DC", "DP", "DW", "DD", "DT", "DK",
    "DR", "EA", "ED", "EB", "DH", "DE", "DG", "PA", "PB", "PG", "PS", "PT", "PY", "SB", "YB",
    "YK", "KS",
))

_ROMAN = ("I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI",
          "XVII", "XVIII", "XIX", "XX", "XXI", "XXII", "XXIII", "XXIV", "XXV", "XXVI", "XXVII", "XXVIII",
          "XXIX", "XXX", "XXXI", "XXXII", "XXXIII", "XXXIV", "XXXV")


class IndonesiaValidator(GatedPlateValidator):
    gate_group = "number"
    reason_area = "Not an Indonesian area code."
    reason_number = "The number is 1 to 9999."
    reason_leading_zero = "The number has no leading zero."
    reason_suffix = "The suffix is up to three letters."
    reason_month = "The expiry month is 01 to 12."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        return self.validate_fields(entry.group("prefix"), entry.group("number"),
                                    entry.group("suffix"), entry.group("month"))

    @classmethod
    def validate_fields(cls, prefix: str, number: str, suffix: str = "", month: str = "") -> PlateValidation:
        if prefix not in INDONESIA_AREA_CODES:
            return PlateValidation.invalid(cls.reason_area)
        if not number or len(number) > 4 or not is_digits(number):
            return PlateValidation.invalid(cls.reason_number)
        if number.startswith("0"):
            return PlateValidation.invalid(cls.reason_leading_zero)
        if len(suffix) > 3:
            return PlateValidation.invalid(cls.reason_suffix)
        if month and not (len(month) == 2 and is_digits(month) and 1 <= int(month) <= 12):
            return PlateValidation.invalid(cls.reason_month)
        return PlateValidation.valid()


class IndonesiaDiplomaticValidator(GatedPlateValidator):
    gate_group = "serial"
    reason_mission = "The code is CD or CC."
    reason_digits = "Both numbers are digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if entry.group("mission") not in ("CD", "CC"):
            return PlateValidation.invalid(self.reason_mission)
        if not is_digits(entry.group("country")) or not is_digits(entry.group("serial")):
            return PlateValidation.invalid(self.reason_digits)
        return PlateValidation.valid()


class IndonesiaServiceValidator(GatedPlateValidator):
    gate_group = "number"
    reason_number = "The number is 1 to 99999."
    reason_suffix = "The suffix is two digits."
    reason_region = "Not a police region numeral."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        number = entry.group("number")
        if not number or not is_digits(number) or number.startswith("0"):
            return PlateValidation.invalid(self.reason_number)
        suffix = entry.group("suffix")
        if len(suffix) != 2 or not is_digits(suffix):
            return PlateValidation.invalid(self.reason_suffix)
        if any(g.key == "region" for g in entry.spec.text_groups) and entry.group("region") not in _ROMAN:
            return PlateValidation.invalid(self.reason_region)
        return PlateValidation.valid()

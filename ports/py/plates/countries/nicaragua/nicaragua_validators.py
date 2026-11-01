"""Port of nicaragua_plate/lib/src/nicaragua_validators.dart."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation, is_digits


class NicaraguaValidator(GatedPlateValidator):
    gate_group = "number"

    departments = {
        "M": "Managua",
        "MY": "Masaya",
        "MT": "Matagalpa",
        "CH": "Chinandega",
        "CT": "Chontales",
        "NS": "Nueva Segovia",
        "ES": "Estelí",
        "JI": "Jinotega",
        "GR": "Granada",
        "LE": "León",
        "RN": "Atlántico Norte",
        "RS": "Atlántico Sur",
        "PN": "Policía Nacional",
        "CD": "Diplomatic corps",
        "CC": "Consular corps",
        "MI": "International mission",
    }

    reason_department = "The letters name no department."
    reason_managua = "Managua numbers have six digits."
    reason_number = "The number has three or four digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if entry.spec.indices_of_group("number_tail") and not entry.group("number_tail"):
            return PlateValidation.valid()
        code = entry.group("department")
        number = entry.group("number") + entry.group("number_tail")
        if code not in self.departments:
            return PlateValidation.invalid(self.reason_department)
        if not self._is_digits(number):
            return PlateValidation.invalid(self.reason_number)
        if code == "M":
            return PlateValidation.valid() if len(number) == 6 else PlateValidation.invalid(self.reason_managua)
        return PlateValidation.valid() if len(number) in (3, 4) else PlateValidation.invalid(self.reason_number)

    @staticmethod
    def _is_digits(s: str) -> bool:
        return is_digits(s)

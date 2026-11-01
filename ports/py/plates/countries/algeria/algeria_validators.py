"""Port of algeria_plate/lib/src/algeria_validators.dart."""
from __future__ import annotations

from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation, is_digits


class AlgeriaVehicleClasses:
    """The vehicle classes the first digit of the `type` group names, by digit."""

    names: dict[str, str] = {
        "1": "Private vehicle",
        "2": "Truck",
        "3": "Commercial vehicle",
        "4": "Bus",
        "5": "Tractor unit",
        "6": "Other tractor",
        "7": "Special vehicle",
        "8": "Trailer",
        "9": "Motorcycle",
    }


class AlgeriaWilayas:
    """The wilaya codes ending a civil plate."""

    names: dict[str, str] = {
        "01": "Adrar",
        "02": "Chlef",
        "03": "Laghouat",
        "04": "Oum El Bouaghi",
        "05": "Batna",
        "06": "Béjaïa",
        "07": "Biskra",
        "08": "Béchar",
        "09": "Blida",
        "10": "Bouïra",
        "11": "Tamanrasset",
        "12": "Tébessa",
        "13": "Tlemcen",
        "14": "Tiaret",
        "15": "Tizi Ouzou",
        "16": "Algiers",
        "17": "Djelfa",
        "18": "Jijel",
        "19": "Sétif",
        "20": "Saïda",
        "21": "Skikda",
        "22": "Sidi Bel Abbès",
        "23": "Annaba",
        "24": "Guelma",
        "25": "Constantine",
        "26": "Médéa",
        "27": "Mostaganem",
        "28": "M'Sila",
        "29": "Mascara",
        "30": "Ouargla",
        "31": "Oran",
        "32": "El Bayadh",
        "33": "Illizi",
        "34": "Bordj Bou Arréridj",
        "35": "Boumerdès",
        "36": "El Tarf",
        "37": "Tindouf",
        "38": "Tissemsilt",
        "39": "El Oued",
        "40": "Khenchela",
        "41": "Souk Ahras",
        "42": "Tipaza",
        "43": "Mila",
        "44": "Aïn Defla",
        "45": "Naâma",
        "46": "Aïn Témouchent",
        "47": "Ghardaïa",
        "48": "Relizane",
        "49": "Timimoun",
        "50": "Bordj Badji Mokhtar",
        "51": "Ouled Djellal",
        "52": "Béni Abbès",
        "53": "In Salah",
        "54": "In Guezzam",
        "55": "Touggourt",
        "56": "Djanet",
        "57": "El M'Ghair",
        "58": "El Menia",
        "59": "Aflou",
        "60": "Barika",
        "61": "El Kantara",
        "62": "Bir El Ater",
        "63": "El Aricha",
        "64": "Ksar Chellala",
        "65": "Aïn Oussera",
        "66": "Messaad",
        "67": "Ksar El Boukhari",
        "68": "Bousaâda",
        "69": "El Abiodh Sidi Cheikh",
    }


class AlgeriaValidator(GatedPlateValidator):
    gate_group = "wilaya"

    reason_serial = "The serial is five digits."
    reason_class = "The vehicle class is 1 to 9."
    reason_type = "The middle group is a class digit and two year digits."
    reason_wilaya = "The wilaya code is 01 to 69."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        return self.validate_fields(
            serial=entry.group("serial"),
            type=entry.group("type"),
            wilaya=entry.group("wilaya"),
        )

    @staticmethod
    def validate_fields(
        serial: str,
        type: str,
        wilaya: str,
    ) -> PlateValidation:
        if not (len(serial) == 5 and is_digits(serial)):
            return PlateValidation.invalid(AlgeriaValidator.reason_serial)
        if not (len(type) == 3 and is_digits(type)):
            return PlateValidation.invalid(AlgeriaValidator.reason_type)
        if type[0] not in AlgeriaVehicleClasses.names:
            return PlateValidation.invalid(AlgeriaValidator.reason_class)
        if wilaya not in AlgeriaWilayas.names:
            return PlateValidation.invalid(AlgeriaValidator.reason_wilaya)
        return PlateValidation.valid()


class AlgeriaDiplomaticValidator(GatedPlateValidator):
    gate_group = "mission"

    reason_digits = "A diplomatic plate is a serial and two two-digit codes."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        serial = entry.group("serial")
        status = entry.group("status")
        mission = entry.group("mission")
        if (
            not serial
            or not is_digits(serial)
            or not (len(status) == 2 and is_digits(status))
            or not (len(mission) == 2 and is_digits(mission))
        ):
            return PlateValidation.invalid(AlgeriaDiplomaticValidator.reason_digits)
        return PlateValidation.valid()

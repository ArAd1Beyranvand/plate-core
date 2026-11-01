"""Port of albania_plate/lib/src/albania_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

import re

from plates.core.validators.plate_validator import (
    GatedPlateValidator,
    PlateEntry,
    PlateValidation,
    is_digits_of_length,
)

_LETTERS2 = re.compile(r"[A-Z]{2}")
_LETTER = re.compile(r"[A-Z]")


class AlbaniaPrivateValidator(GatedPlateValidator):
    gate_group = 'series'

    reason_series = 'The series is two letters.'
    reason_number = 'The number is three digits.'
    reason_suffix = 'The suffix is two letters.'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if not _LETTERS2.fullmatch(entry.group('series')):
            return PlateValidation.invalid(self.reason_series)
        if not is_digits_of_length(entry.group('number'), 3):
            return PlateValidation.invalid(self.reason_number)
        suffix = entry.group('suffix')
        if suffix and not _LETTERS2.fullmatch(suffix):
            return PlateValidation.invalid(self.reason_suffix)
        return PlateValidation.valid()


class AlbaniaAgriculturalValidator(GatedPlateValidator):
    gate_group = 'series'

    classes = ('MB', 'MT', 'RB', 'RT', 'R')

    reason_series = 'The series is two letters.'
    reason_class = 'The class is MB, MT, RB, RT or R.'
    reason_number = 'The number is three digits after R, two after the others.'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if not _LETTERS2.fullmatch(entry.group('series')):
            return PlateValidation.invalid(self.reason_series)
        kind = entry.group('class')
        if kind not in self.classes:
            return PlateValidation.invalid(self.reason_class)
        if not is_digits_of_length(entry.group('number'), 3 if kind == 'R' else 2):
            return PlateValidation.invalid(self.reason_number)
        return PlateValidation.valid()


class AlbaniaDiplomaticValidator(GatedPlateValidator):
    gate_group = 'prefix'

    reason_prefix = 'The prefix is CD or TR.'
    reason_code = 'The mission code is two digits.'
    reason_number = 'The number is two digits.'
    reason_suffix = 'The rank is one letter.'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if entry.group('prefix') not in ('CD', 'TR'):
            return PlateValidation.invalid(self.reason_prefix)
        if not is_digits_of_length(entry.group('code'), 2):
            return PlateValidation.invalid(self.reason_code)
        if not is_digits_of_length(entry.group('number'), 2):
            return PlateValidation.invalid(self.reason_number)
        if not _LETTER.fullmatch(entry.group('suffix')):
            return PlateValidation.invalid(self.reason_suffix)
        return PlateValidation.valid()


class AlbaniaMilitaryValidator(GatedPlateValidator):
    gate_group = 'prefix'

    branches = ('FA', 'FD', 'FT', 'KM', 'PU', 'SP')

    reason_prefix = 'The prefix is MM.'
    reason_number = 'The number is three digits.'
    reason_suffix = 'The branch is FA, FD, FT, KM, PU or SP.'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if entry.group('prefix') != 'MM':
            return PlateValidation.invalid(self.reason_prefix)
        if not is_digits_of_length(entry.group('number'), 3):
            return PlateValidation.invalid(self.reason_number)
        if entry.group('suffix') not in self.branches:
            return PlateValidation.invalid(self.reason_suffix)
        return PlateValidation.valid()


class AlbaniaPoliceValidator(GatedPlateValidator):
    gate_group = 'prefix'

    reason_prefix = 'The prefix is MB.'
    reason_number = 'The number is three digits.'
    reason_suffix = 'The suffix is two letters.'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if entry.group('prefix') != 'MB':
            return PlateValidation.invalid(self.reason_prefix)
        if not is_digits_of_length(entry.group('number'), 3):
            return PlateValidation.invalid(self.reason_number)
        if not _LETTERS2.fullmatch(entry.group('suffix')):
            return PlateValidation.invalid(self.reason_suffix)
        return PlateValidation.valid()


class AlbaniaTaxiValidator(GatedPlateValidator):
    gate_group = 'series'

    reason_series = 'The series is two letters.'
    reason_number = 'The number is three digits.'
    reason_suffix = 'A taxi plate ends in T.'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if not _LETTERS2.fullmatch(entry.group('series')):
            return PlateValidation.invalid(self.reason_series)
        if not is_digits_of_length(entry.group('number'), 3):
            return PlateValidation.invalid(self.reason_number)
        if entry.group('suffix') != 'T':
            return PlateValidation.invalid(self.reason_suffix)
        return PlateValidation.valid()


class AlbaniaProvisionalValidator(GatedPlateValidator):
    gate_group = 'series'

    reason_series = 'The series is two letters.'
    reason_number = 'The number is one digit.'
    reason_word = 'The word is PRK (temporary) or PROV (test).'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if not _LETTERS2.fullmatch(entry.group('series')):
            return PlateValidation.invalid(self.reason_series)
        if not is_digits_of_length(entry.group('number'), 1):
            return PlateValidation.invalid(self.reason_number)
        if entry.group('word') not in ('PRK', 'PROV'):
            return PlateValidation.invalid(self.reason_word)
        return PlateValidation.valid()

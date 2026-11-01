import dataclasses

import pytest

from plates.core.model.plate_alphabet import AlphabetInput, PlateAlphabet
from plates.core.model.plate_box import PlateBox
from plates.core.model.plate_country import PlateCountry
from plates.core.model.plate_layout import plate_register, plate_register_across
from plates.core.model.plate_restriction import PlateRestriction, PlateRestrictionError
from plates.core.model.plate_spec import PlateMirror, PlateSpec, PlateTextGroup
from plates.core.theme.plate_theme import PlateTheme
from plates.core.validators.debug_validate_spec import spec_problems
from plates.core.validators.plate_validator import (
    PlateEntry, PlateValidation, is_digits, is_digits_of_length, restriction_verdict,
)

DIGITS = PlateAlphabet.pattern("d", "0-9", AlphabetInput.TYPED, True)


def make_spec(slots, **kw):
    return PlateSpec("t.x", None, 100, 50, None, tuple(slots), **kw)


def test_is_digits_ascii_only():
    assert is_digits("0123") and not is_digits("") and not is_digits("۵") and not is_digits("²")
    assert is_digits_of_length("12", 2) and not is_digits_of_length("12", 3)


def test_register_builders():
    s = plate_register_across(DIGITS, 4, 0, 40, 5, 10)
    assert [x.box.left for x in s] == [0, 10, 20, 30] and isinstance(s, tuple)
    assert plate_register(DIGITS, 2, 1, 2, 3, 4, pitch=5)[1].box == PlateBox(6, 2, 3, 4)
    with pytest.raises(ValueError):
        plate_register(DIGITS, -1, 0, 0, 1, 1)


def test_sound_spec_has_no_problems():
    assert spec_problems(make_spec(plate_register(DIGITS, 3, 0, 0, 10, 10))) == []


def test_problems_reported():
    slots = list(plate_register(DIGITS, 3, 0, 0, 10, 10)) + [plate_register(DIGITS, 1, 95, 0, 10, 10)[0]]
    spec = make_spec(
        slots, mirrors=(PlateMirror(9, PlateBox(0, 0, 1, 1), 1),),
        text_groups=(PlateTextGroup((0, 1, 2), key="a"),),
        restrictions=(PlateRestriction("zz", ("1",), "no"),),
    )
    p = spec_problems(spec)
    assert 'PlateSlot 3 in spec "t.x" has a rect outside the canvas (100.0x50.0).' in p
    assert any("echoes slot 9" in x for x in p)
    assert any("watches group" in x for x in p)


def test_restriction():
    spec = make_spec(plate_register(DIGITS, 2, 0, 0, 10, 10),
                     text_groups=(PlateTextGroup((0, 1), key="n"),),
                     restrictions=(PlateRestriction("n", ("09",), "banned"),))
    assert restriction_verdict(PlateEntry(spec, ["0", "9"])) == PlateValidation.invalid("banned")
    assert restriction_verdict(PlateEntry(spec, ["0", ""])) is None
    with pytest.raises(PlateRestrictionError, match="banned"):
        spec.check_restrictions(["0", "9"])


def test_theme():
    a, b = PlateTheme.standard(), PlateTheme.monochrome(0xFF000000, 0xFFFFFFFF, 0, 0.08, 0.2)
    assert a == PlateTheme.standard() and a.copy_with(ink=1) != a
    assert PlateTheme.lerp(a, b, 0) == a and PlateTheme.lerp(a, b, 1) == b
    assert PlateTheme.lerp(a, b, 0.5).border_width_ratio == pytest.approx(0.06)
    assert a.glyph_style(100, 5).pixel_size == pytest.approx(72)
    with pytest.raises(dataclasses.FrozenInstanceError):
        a.ink = 0

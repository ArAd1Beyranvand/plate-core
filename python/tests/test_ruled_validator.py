from types import SimpleNamespace

from plates.core.validators.plate_validator import PlateCheck, RuledPlateValidator


def entry(**groups):
    """An entry that reads its groups from keywords and has no restrictions."""
    return SimpleNamespace(group=lambda k: groups.get(k, ""), spec=SimpleNamespace(restriction_violated_by=lambda v: None), values=[])


class Plate(RuledPlateValidator):
    checks = (PlateCheck("letters", "[A-Z]{2}", "two letters"), PlateCheck("tail", "[0-9]{1,2}", "a tail", True),
              PlateCheck("serial", "[0-9]{4}", "four digits"))


def test_a_check_matches_its_whole_group_and_an_optional_one_may_be_empty():
    assert PlateCheck("g", "[A-Z]{2}", "r").passes("AB")
    assert not PlateCheck("g", "[A-Z]{2}", "r").passes("ABC")
    assert not PlateCheck("g", "A|B", "r").passes("AB")
    assert not PlateCheck("g", "[0-9]+", "r").passes("٣")
    assert PlateCheck("g", "[0-9]+", "r", True).passes("")


def test_the_first_failing_check_gives_the_reason_and_the_last_is_the_gate():
    v = Plate()
    assert v.gate_group == "serial"
    assert v.validate(entry(letters="AB", serial="1234")).reason is None
    assert v.validate(entry(letters="A", serial="12")).reason == "two letters"
    assert v.validate(entry(letters="AB", tail="123", serial="1234")).reason == "a tail"
    assert v.validate(entry(letters="AB", serial="12")).reason == "four digits"


def test_stays_quiet_until_the_gate_group_has_content():
    assert Plate().validate(entry(letters="A")).reason is None

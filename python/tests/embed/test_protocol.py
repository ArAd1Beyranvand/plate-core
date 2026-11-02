import json
from pathlib import Path

import pytest

from plates.embed.protocol import validate

CASES = json.loads((Path(__file__).resolve().parents[3] / "web" / "protocol_vectors.json").read_text(encoding="utf8"))["cases"]


@pytest.mark.parametrize("case", CASES, ids=lambda c: c["name"])
def test_vector(case):
    assert validate(case["dir"], case["message"]) is case["valid"]


def test_bool_is_not_a_number_or_version():
    ok = {"ns": "plate-embed", "v": 1, "type": "resize", "payload": {"height": 1}}
    assert validate("C2H", ok)
    assert not validate("C2H", {**ok, "v": True})
    assert not validate("C2H", {**ok, "payload": {"height": True}})

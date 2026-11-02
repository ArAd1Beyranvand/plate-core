"""Runs ports/vectors against a hand-ported unit; the generated tests/countries/*/test_*.py call these."""
from dataclasses import asdict
from importlib import import_module

from plates.core.validators.plate_validator import PlateEntry
from tests.specs import snake, theme_of
from tests.vectors import load_vectors


def _spec(case):
    i = case["input"]
    return import_module(f"plates.countries.{i['package'].removesuffix('_plate')}.data").SPECS[i["spec"]]


def _freeze(x):
    return tuple(map(_freeze, x)) if isinstance(x, list) else x


def check_validator(cls):
    for case in load_vectors(f"validators/{cls.__name__}.json"):
        i = case["input"]
        if i["validator"]["class"] != cls.__name__: continue
        args = {snake(k): _freeze(v) for k, v in i["validator"].get("args", {}).items()}
        got = cls(**args).validate(PlateEntry(_spec(case), i["values"]))
        assert {"valid": got.is_valid, "reason": got.reason} == case["expect"], case["name"]


def check_resolver(name):
    """Resolves through the spec's own hook, so the generated wiring is tested too."""
    for case in load_vectors(f"resolvers/{name}.json"):
        i = case["input"]
        spec = _spec(case)
        at = i["at"]
        resolve = spec.labels[int(at.split("/")[1])].resolve if "/" in at else getattr(spec, snake(at))
        groups = i["groups"]
        group = lambda key: groups[key]
        if "base" in i:
            got = asdict(resolve(theme_of(i["base"]), group))
            assert got == {snake(k): v for k, v in case["expect"].items()}, case["name"]
        else:
            assert resolve(group) == case["expect"], case["name"]

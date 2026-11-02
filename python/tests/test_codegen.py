"""The generated country modules: `[D4-table]` rows reach the spec hooks, and no country imports another (W7)."""
from dataclasses import asdict
from pathlib import Path

import pytest

from plates.countries import COUNTRIES, load
from tests.specs import DATA, package, snake

OUT = Path(__file__).resolve().parents[1] / "plates" / "countries"


def _table_hooks():
    for f in sorted((DATA / "countries").glob("*.json")):
        d = package(f.stem)
        for s in d["specs"]:
            hooks = [(at, s[at]) for at in ("resolveTheme", "resolveRegion")]
            hooks += [(f"labels/{i}", l["resolve"]) for i, l in enumerate(s["labels"])]
            for at, key in hooks:
                if key and d["resolvers"][key]["kind"] == "table":
                    yield pytest.param(f.stem, s["id"], at, key, id=f"{s['id']}:{at}")


@pytest.mark.parametrize("pkg,spec_id,at,key", _table_hooks())
def test_table_resolver(pkg, spec_id, at, key):
    data = load(pkg.removesuffix("_plate"))
    spec = data.SPECS[spec_id]
    resolve = spec.labels[int(at.split("/")[1])].resolve if "/" in at else getattr(spec, snake(at))
    r = package(pkg)["resolvers"][key]
    base = next(iter(data.THEMES.values()), None)
    rows = [(dict(zip(r["reads"], k)), v) for k, v in r["table"]]
    rows.append(({g: "￿" for g in r["reads"]}, r["default"]))  # an unlisted key
    for groups, want in rows:
        group = lambda g: groups.get(g, "")
        if r["signature"] == "label":
            assert resolve(group) == want, groups
        else:
            got = asdict(resolve(base, group))
            assert got == {**asdict(base), **{snake(k): v for k, v in (want or {}).items()}}, groups


def test_countries_import_only_the_core_and_their_own_units():
    assert len(COUNTRIES) == len(list((DATA / "countries").glob("*.json")))
    for country in COUNTRIES:
        for f in (OUT / country).glob("*.py"):
            for line in f.read_text(encoding="utf8").splitlines():
                if line.startswith(("import ", "from ")) and "plates" in line:
                    mod = line.split()[1]
                    assert mod.startswith((".", "plates.core.", "plates.countries.tables")), (f, line)

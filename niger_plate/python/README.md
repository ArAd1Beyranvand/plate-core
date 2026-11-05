FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the resilient people of Niger to view examples:

https://platexample.ir/#/discover/niger:python

# niger_plate

Niger's licence plates for plate_core: the 2005 series in private and commercial liveries, with themes, alphabets and advisory validators.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/niger-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/niger:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/niger-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/niger:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/niger-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/niger:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/niger-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/niger:typescript) |

## Quick start

### Install (Python)

Copy `python/plates/countries/niger/` into `plate_core/python/plates/countries/`.

Then run the tests from `plate_core/python/`: `pytest`.

### Use

```python
from plates.countries.niger.data import SPECS, THEMES

spec = SPECS["ne.2005.state"]
theme = THEMES["NigerThemes.private"]
print(spec.id)
```

## Specs

The specs are the same in every language (they come from shared data).

- `ne.2005.state`
- `ne.2005.military`
- `ne.2005.diplomatic.cmd`
- `ne.2005.diplomatic.cd`
- `ne.2005.private`
- `ne.2005.commercial`

## Themes

- `NigerThemes.private`
- `NigerThemes.commercial`
- `NigerThemes.stateTransport`
- `NigerThemes.military`
- `NigerThemes.diplomatic`

## Change it

- Pick a spec: use another key of `SPECS`.
- Pick a theme: use another key of `THEMES`.
- Validators: `VALIDATORS` maps the names `NigerValidator`, `NigerStateValidator`, `NigerMilitaryValidator`, `NigerDiplomaticValidator` to classes.

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/niger-plate/blob/main/LICENSE).

FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the resilient people of Bolivia to view examples:

https://platexample.ir/#/discover/bolivia:python

# bolivia_plate

Bolivia's licence plates for plate_core: standard, diplomatic, consular and Mercosur plates, with themes, alphabets and advisory validators.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/bolivia-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/bolivia:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/bolivia-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/bolivia:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/bolivia-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/bolivia:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/bolivia-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/bolivia:typescript) |

## Quick start

### Install (Python)

Copy `python/plates/countries/bolivia/` into `plate_core/python/plates/countries/`.

Then run the tests from `plate_core/python/`: `pytest`.

### Use

```python
from plates.countries.bolivia.data import SPECS, THEMES

spec = SPECS["bo.mercosur"]
theme = THEMES["BoliviaThemes.standard"]
print(spec.id)
```

## Specs

The specs are the same in every language (they come from shared data).

- `bo.mercosur`
- `bo.pta4.priv`
- `bo.pta3.priv`
- `bo.pta4.pub`
- `bo.pta4.gov`
- `bo.cc`
- `bo.cd`
- `bo.mi`
- `bo.oi`

## Themes

- `BoliviaThemes.standard`
- `BoliviaThemes.diplomatic`
- `BoliviaThemes.consular`
- `BoliviaThemes.mission`
- `BoliviaThemes.organization`
- `BoliviaThemes.mercosur`

## Change it

- Pick a spec: use another key of `SPECS`.
- Pick a theme: use another key of `THEMES`.
- Validators: `VALIDATORS` maps the names `BoliviaValidator`, `BoliviaSpecialValidator`, `BoliviaMercosurValidator` to classes.

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/bolivia-plate/blob/main/LICENSE).

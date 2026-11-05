FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the vibrant people of India to view examples:

https://platexample.ir/#/discover/india:python

# india_plate

India's licence plates for the plate_core library — the HSRP car plate in every colour class, with the Bharat, vintage, armed-forces, diplomatic, temporary and trade formats.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/india-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/india:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/india-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/india:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/india-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/india:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/india-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/india:typescript) |

## Quick start

### Install (Python)

Copy `python/plates/countries/india/` into `plate_core/python/plates/countries/`.

Then run the tests from `plate_core/python/`: `pytest`.

### Use

```python
from plates.countries.india.data import SPECS, THEMES

spec = SPECS["in.private"]
theme = THEMES["IndiaThemes.private"]
print(spec.id)
```

## Specs

The specs are the same in every language (they come from shared data).

- `in.private`
- `in.standard`
- `in.bharat`
- `in.vintage`
- `in.military`
- `in.diplomatic`
- `in.temporary`
- `in.trade`

## Themes

- `IndiaThemes.private`
- `IndiaThemes.transport`
- `IndiaThemes.rental`
- `IndiaThemes.electric`
- `IndiaThemes.electricTransport`
- `IndiaThemes.diplomatic`
- `IndiaThemes.consular`
- `IndiaThemes.military`
- `IndiaThemes.militaryPolice`
- `IndiaThemes.temporary`
- `IndiaThemes.trade`

## Change it

- Pick a spec: use another key of `SPECS`.
- Pick a theme: use another key of `THEMES`.
- Validators: `VALIDATORS` maps the names `IndiaValidator` to classes.

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/india-plate/blob/main/LICENSE).

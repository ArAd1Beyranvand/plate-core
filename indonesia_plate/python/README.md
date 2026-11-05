FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the friendly people of Indonesia to view examples:

https://platexample.ir/#/discover/indonesia:python

# indonesia_plate

Indonesia's licence plates for plate_core: car, motorcycle, diplomatic, armed-forces and police plates, with usage and EV liveries and advisory validators.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/indonesia-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/indonesia:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/indonesia-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/indonesia:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/indonesia-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/indonesia:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/indonesia-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/indonesia:typescript) |

## Quick start

### Install (Python)

Copy `python/plates/countries/indonesia/` into `plate_core/python/plates/countries/`.

Then run the tests from `plate_core/python/`: `pytest`.

### Use

```python
from plates.countries.indonesia.data import SPECS, THEMES

spec = SPECS["id.car"]
theme = THEMES["IndonesiaThemes.private"]
print(spec.id)
```

## Specs

The specs are the same in every language (they come from shared data).

- `id.car`
- `id.motorcycle`
- `id.diplomatic`
- `id.police`
- `id.military.army`
- `id.military.navy`
- `id.military.airForce`
- `id.military.armedForces`

## Themes

- `IndonesiaThemes.private`
- `IndonesiaThemes.public`
- `IndonesiaThemes.government`
- `IndonesiaThemes.freeTradeZone`
- `IndonesiaThemes.privateEv`
- `IndonesiaThemes.publicEv`
- `IndonesiaThemes.governmentEv`
- `IndonesiaThemes.freeTradeZoneEv`
- `IndonesiaThemes.diplomatic`
- `IndonesiaThemes.diplomaticEv`
- `IndonesiaThemes.army`
- `IndonesiaThemes.navy`
- `IndonesiaThemes.airForce`
- `IndonesiaThemes.armedForces`
- `IndonesiaThemes.police`

## Change it

- Pick a spec: use another key of `SPECS`.
- Pick a theme: use another key of `THEMES`.
- Validators: `VALIDATORS` maps the names `IndonesiaValidator`, `IndonesiaDiplomaticValidator`, `IndonesiaServiceValidator` to classes.

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/indonesia-plate/blob/main/LICENSE).

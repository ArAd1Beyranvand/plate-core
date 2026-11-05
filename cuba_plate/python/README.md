FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the brave people of Cuba to view examples:

https://platexample.ir/#/discover/cuba:python

# cuba_plate

Cuba's licence plates for plate_core: the 2013 car plate (natural-person and legal-entity strips) and motorcycle plate, with alphabet and advisory validator.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/cuba-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/cuba:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/cuba-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/cuba:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/cuba-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/cuba:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/cuba-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/cuba:typescript) |

## Quick start

### Install (Python)

Copy `python/plates/countries/cuba/` into `plate_core/python/plates/countries/`.

Then run the tests from `plate_core/python/`: `pytest`.

### Use

```python
from plates.countries.cuba.data import SPECS, THEMES

spec = SPECS["cu.car"]
theme = THEMES["CubaPlates.theme"]
print(spec.id)
```

## Specs

The specs are the same in every language (they come from shared data).

- `cu.car`
- `cu.carLegalEntity`
- `cu.motorcycle`

## Themes

- `CubaPlates.theme`

## Change it

- Pick a spec: use another key of `SPECS`.
- Pick a theme: use another key of `THEMES`.
- Validators: `VALIDATORS` maps the names `CubaValidator` to classes.

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/cuba-plate/blob/main/LICENSE).

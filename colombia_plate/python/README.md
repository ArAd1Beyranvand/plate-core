FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the warm people of Colombia to view examples:

https://platexample.ir/#/discover/colombia:python

# colombia_plate

Colombia's licence plates for plate_core: private, public-service, official, diplomatic and police plates, with themes, alphabets and advisory validators.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/colombia-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/colombia:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/colombia-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/colombia:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/colombia-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/colombia:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/colombia-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/colombia:typescript) |

## Quick start

### Install (Python)

Copy `python/plates/countries/colombia/` into `plate_core/python/plates/countries/`.

Then run the tests from `plate_core/python/`: `pytest`.

### Use

```python
from plates.countries.colombia.data import SPECS, THEMES

spec = SPECS["co.police"]
theme = THEMES["ColombiaThemes.private"]
print(spec.id)
```

## Specs

The specs are the same in every language (they come from shared data).

- `co.police`
- `co.cd`
- `co.private`
- `co.commercial`
- `co.official`
- `co.antique`
- `co.mototaxi`
- `co.trailer`
- `co.tank`
- `co.cc`
- `co.oi`
- `co.at`

## Themes

- `ColombiaThemes.private`
- `ColombiaThemes.commercial`
- `ColombiaThemes.official`
- `ColombiaThemes.antique`
- `ColombiaThemes.tank`
- `ColombiaThemes.consular`
- `ColombiaThemes.organization`
- `ColombiaThemes.staff`
- `ColombiaThemes.police`
- `ColombiaThemes.diplomatic`

## Change it

- Pick a spec: use another key of `SPECS`.
- Pick a theme: use another key of `THEMES`.
- Validators: `VALIDATORS` maps the names `ColombiaValidator`, `ColombiaPoliceValidator`, `ColombiaDiplomaticValidator` to classes.

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/colombia-plate/blob/main/LICENSE).

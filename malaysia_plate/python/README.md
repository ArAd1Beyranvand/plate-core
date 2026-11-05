FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the harmonious people of Malaysia to view examples:

https://platexample.ir/#/discover/malaysia:python

# malaysia_plate

Malaysia's licence plates for plate_core: single-row and two-row JPJ plates, the diplomatic plate and JPJePlate, with themes, alphabets and an advisory validator.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/malaysia-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/malaysia:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/malaysia-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/malaysia:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/malaysia-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/malaysia:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/malaysia-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/malaysia:typescript) |

## Quick start

### Install (Python)

Copy `python/plates/countries/malaysia/` into `plate_core/python/plates/countries/`.

Then run the tests from `plate_core/python/`: `pytest`.

### Use

```python
from plates.countries.malaysia.data import SPECS, THEMES

spec = SPECS["my.diplomatic"]
theme = THEMES["MalaysiaThemes.standard"]
print(spec.id)
```

## Specs

The specs are the same in every language (they come from shared data).

- `my.diplomatic`
- `my.single.plain`
- `my.single.suffix`
- `my.twoRow.plain`
- `my.ev.plain`

## Themes

- `MalaysiaThemes.standard`
- `MalaysiaThemes.taxi`
- `MalaysiaThemes.diplomatic`
- `MalaysiaThemes.ev`

## Change it

- Pick a spec: use another key of `SPECS`.
- Pick a theme: use another key of `THEMES`.
- Validators: `VALIDATORS` maps the names `MalaysiaValidator`, `MalaysiaDiplomaticValidator` to classes.

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/malaysia-plate/blob/main/LICENSE).

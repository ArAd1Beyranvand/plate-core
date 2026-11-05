FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the resilient people of Bolivia to view examples:

https://platexample.ir/#/discover/bolivia:typescript

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

### Install (TypeScript)

Copy `typescript/src/countries/bolivia/` into `plate_core/typescript/src/countries/`.

Then run the tests from `plate_core/typescript/`: `npm test`.

### Use

```ts
import country from './countries/bolivia';

const spec = country.specs.get('bo.mercosur');
console.log(country.package);
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

- Specs: `country.specs`, by id.
- Themes: `country.themes`.
- Validators: `country.validators` (`BoliviaValidator`, `BoliviaSpecialValidator`, `BoliviaMercosurValidator`).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/bolivia-plate/blob/main/LICENSE).

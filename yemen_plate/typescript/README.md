FREE PALESTINE 🇵🇸🇮🇷 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the noble people of Yemen to view examples:

https://platexample.ir/#/discover/yemen:typescript

# yemen_plate

Yemen's licence plates for the plate_core library — the 2026 unified specs, the 1993 northern specs, the alphabets, the usage themes and the advisory validators.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/yemen-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/yemen:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/yemen-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/yemen:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/yemen-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/yemen:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/yemen-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/yemen:typescript) |

## Quick start

### Install (TypeScript)

Copy `typescript/src/countries/yemen/` into `plate_core/typescript/src/countries/`.

Then run the tests from `plate_core/typescript/`: `npm test`.

### Use

```ts
import country from './countries/yemen';

const spec = country.specs.get('ye.northern.car');
console.log(country.package);
```

## Specs

The specs are the same in every language (they come from shared data).

- `ye.northern.car`
- `ye.riyadh.us`
- `ye.riyadh.us.diplomatic`
- `ye.riyadh.eu`
- `ye.riyadh.eu.diplomatic`
- `ye.aden.520x110`
- `ye.aden.335x170`
- `ye.taiz.temporary`
- `ye.hadhramaut.car.s5`
- `ye.hadhramaut.temporary.s4`
- `ye.hadhramaut.police.s3`
- `ye.hadhramaut.moto.s4`
- `ye.mahrah.car.s4`
- `ye.mahrah.moto.s4`
- `ye.shabwah.car.s4`
- `ye.shabwah.temporary.s4`
- `ye.shabwah.police.s3`
- `ye.shabwah.moto.s3`
- `ye.marib.car.s4`
- `ye.marib.moto.s4`
- `ye.unified.car`
- `ye.unified.moto`
- `ye.northern.moto`

## Themes

- `YemenThemes.unified`
- `YemenThemes.northernPrivate`
- `YemenThemes.northernForHire`
- `YemenThemes.northernTransport`
- `YemenThemes.northernGovernment`
- `YemenThemes.northernMilitaryClassic`
- `YemenThemes.northernMilitaryModern`
- `YemenThemes.southern`
- `YemenThemes.aden`
- `YemenThemes.taizPrivate`
- `YemenThemes.taizCommercial`
- `RiyadhThemes.standard`

## Change it

- Specs: `country.specs`, by id.
- Themes: `country.themes`.
- Validators: `country.validators` (`YemenUnifiedValidator`, `YemenNorthernValidator`, `YemenSouthernValidator`, `RiyadhValidator`).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/yemen-plate/blob/main/LICENSE).

FREE PALESTINE 🇵🇸🇮🇷 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the free people of Palestine to view examples:

https://platexample.ir/#/discover/palestine:typescript

# palestine_plate

Palestine's licence plates for the plate_core library — the West Bank and Gaza specs, the alphabets, the usage themes and the advisory validators.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/palestine-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/palestine:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/palestine-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/palestine:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/palestine-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/palestine:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/palestine-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/palestine:typescript) |

## Quick start

### Install (TypeScript)

Copy `typescript/src/countries/palestine/` into `plate_core/typescript/src/countries/`.

Then run the tests from `plate_core/typescript/`: `npm test`.

### Use

```ts
import country from './countries/palestine';

const spec = country.specs.get('ps.gz.2012.car');
console.log(country.package);
```

## Specs

The specs are the same in every language (they come from shared data).

- `ps.gz.2012.car`
- `ps.gz.moto`
- `ps.gz.2012.car2l`
- `ps.gz.2021.car2l`
- `ps.wb.modern.car`
- `ps.wb.legacy.car`
- `ps.wb.modern.car2l`
- `ps.wb.legacy.car2l`
- `ps.wb.modern.moto`
- `ps.wb.modern.moto2l`
- `ps.wb.modern.trade`

## Themes

- `PSThemes.greenOnWhite`
- `PSThemes.whiteOnGreen`
- `PSThemes.redOnWhite`
- `PSThemes.whiteOnBlue`
- `PSThemes.gazaBlack`
- `PSThemes.gazaGreen`
- `PSThemes.gazaBlue`

## Change it

- Specs: `country.specs`, by id.
- Themes: `country.themes`.
- Validators: `country.validators` (`PSWestBankModernValidator`, `PSWestBankLegacyValidator`, `PSGazaValidator`).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/palestine-plate/blob/main/LICENSE).

FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the resilient people of Sudan to view examples:

https://platexample.ir/#/discover/sudan:typescript

# sudan_plate

Sudan's licence plates for plate_core: the bilingual 2009 plate in private, bus-and-taxi and commercial liveries, with themes, alphabets and advisory validators.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/sudan-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/sudan:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/sudan-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/sudan:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/sudan-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/sudan:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/sudan-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/sudan:typescript) |

## Quick start

### Install (TypeScript)

Copy `typescript/src/countries/sudan/` into `plate_core/typescript/src/countries/`.

Then run the tests from `plate_core/typescript/`: `npm test`.

### Use

```ts
import country from './countries/sudan';

const spec = country.specs.get('sd.2009');
console.log(country.package);
```

## Specs

The specs are the same in every language (they come from shared data).

- `sd.2009`

## Themes

- `SudanThemes.private`
- `SudanThemes.transport`
- `SudanThemes.commercial`

## Change it

- Specs: `country.specs`, by id.
- Themes: `country.themes`.
- Validators: `country.validators` (`SudanValidator`).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/sudan-plate/blob/main/LICENSE).

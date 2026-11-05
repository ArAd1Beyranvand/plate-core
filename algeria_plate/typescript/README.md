FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the brave people of Algeria to view examples:

https://platexample.ir/#/discover/algeria:typescript

# algeria_plate

Algeria's licence plates for plate_core: single-line and two-line plates, diplomatic and army plates, with themes, alphabets and an advisory validator.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/algeria-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/algeria:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/algeria-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/algeria:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/algeria-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/algeria:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/algeria-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/algeria:typescript) |

## Quick start

### Install (TypeScript)

Copy `typescript/src/countries/algeria/` into `plate_core/typescript/src/countries/`.

Then run the tests from `plate_core/typescript/`: `npm test`.

### Use

```ts
import country from './countries/algeria';

const spec = country.specs.get('dz.singleLine');
console.log(country.package);
```

## Specs

The specs are the same in every language (they come from shared data).

- `dz.singleLine`
- `dz.twoLine`
- `dz.diplomatic`
- `dz.army`

## Themes

- `AlgeriaThemes.front`
- `AlgeriaThemes.rear`
- `AlgeriaThemes.diplomatic`
- `AlgeriaThemes.army`

## Change it

- Specs: `country.specs`, by id.
- Themes: `country.themes`.
- Validators: `country.validators` (`AlgeriaValidator`, `AlgeriaDiplomaticValidator`).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/algeria-plate/blob/main/LICENSE).

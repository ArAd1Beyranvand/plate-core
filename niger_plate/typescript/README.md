FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the resilient people of Niger to view examples:

https://platexample.ir/#/discover/niger:typescript

# niger_plate

Niger's licence plates for plate_core: the 2005 series in private and commercial liveries, with themes, alphabets and advisory validators.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/niger-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/niger:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/niger-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/niger:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/niger-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/niger:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/niger-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/niger:typescript) |

## Quick start

### Install (TypeScript)

Copy `typescript/src/countries/niger/` into `plate_core/typescript/src/countries/`.

Then run the tests from `plate_core/typescript/`: `npm test`.

### Use

```ts
import country from './countries/niger';

const spec = country.specs.get('ne.2005.state');
console.log(country.package);
```

## Specs

The specs are the same in every language (they come from shared data).

- `ne.2005.state`
- `ne.2005.military`
- `ne.2005.diplomatic.cmd`
- `ne.2005.diplomatic.cd`
- `ne.2005.private`
- `ne.2005.commercial`

## Themes

- `NigerThemes.private`
- `NigerThemes.commercial`
- `NigerThemes.stateTransport`
- `NigerThemes.military`
- `NigerThemes.diplomatic`

## Change it

- Specs: `country.specs`, by id.
- Themes: `country.themes`.
- Validators: `country.validators` (`NigerValidator`, `NigerStateValidator`, `NigerMilitaryValidator`, `NigerDiplomaticValidator`).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/niger-plate/blob/main/LICENSE).

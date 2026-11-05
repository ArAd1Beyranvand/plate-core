FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the harmonious people of Malaysia to view examples:

https://platexample.ir/#/discover/malaysia:kotlin

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

### Install (Kotlin)

Copy `kotlin/src/commonMain/kotlin/plates/countries/malaysia/` into `plate_core/kotlin/src/commonMain/kotlin/plates/countries/`.

Then run the tests from `plate_core/kotlin/`: `./gradlew jvmTest`.

### Use

```kotlin
import plates.countries.malaysia.country

val spec = country.specs["my.diplomatic"]
println(country.pkg)
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

- Specs: `country.specs`, by id.
- Themes: `country.themes`.
- Validators: `country.validators` (`MalaysiaValidator`, `MalaysiaDiplomaticValidator`).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/malaysia-plate/blob/main/LICENSE).

FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the brave people of Algeria to view examples:

https://platexample.ir/#/discover/algeria:kotlin

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

### Install (Kotlin)

Copy `kotlin/src/commonMain/kotlin/plates/countries/algeria/` into `plate_core/kotlin/src/commonMain/kotlin/plates/countries/`.

Then run the tests from `plate_core/kotlin/`: `./gradlew jvmTest`.

### Use

```kotlin
import plates.countries.algeria.country

val spec = country.specs["dz.singleLine"]
println(country.pkg)
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

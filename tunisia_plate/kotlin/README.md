FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the brave people of Tunisia to view examples:

https://platexample.ir/#/discover/tunisia:kotlin

# tunisia_plate

Tunisia's licence plates for plate_core: one- and two-line, rental, government, diplomatic, military and temporary plates, with themes, alphabets and validators.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/tunisia-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/tunisia:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/tunisia-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/tunisia:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/tunisia-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/tunisia:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/tunisia-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/tunisia:typescript) |

## Quick start

### Install (Kotlin)

Copy `kotlin/src/commonMain/kotlin/plates/countries/tunisia/` into `plate_core/kotlin/src/commonMain/kotlin/plates/countries/`.

Then run the tests from `plate_core/kotlin/`: `./gradlew jvmTest`.

### Use

```kotlin
import plates.countries.tunisia.country

val spec = country.specs["tn.standard"]
println(country.pkg)
```

## Specs

The specs are the same in every language (they come from shared data).

- `tn.standard`
- `tn.square`
- `tn.government`
- `tn.military`
- `tn.diplomatic.cd`
- `tn.diplomatic.md`
- `tn.diplomatic.cmd`
- `tn.temporary.rs`

## Themes

- `TunisiaThemes.standard`
- `TunisiaThemes.rental`
- `TunisiaThemes.government`
- `TunisiaThemes.diplomatic`
- `TunisiaThemes.military`

## Change it

- Specs: `country.specs`, by id.
- Themes: `country.themes`.
- Validators: `country.validators` (`TunisiaValidator`, `TunisiaGovernmentValidator`, `TunisiaDiplomaticValidator`, `TunisiaSerialValidator`).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/tunisia-plate/blob/main/LICENSE).

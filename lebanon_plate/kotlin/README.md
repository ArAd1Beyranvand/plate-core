FREE PALESTINE 🇵🇸🇮🇷 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the steadfast people of Lebanon to view examples:

https://platexample.ir/#/discover/lebanon:kotlin

# lebanon_plate

Lebanon's licence plates for the plate_core library — the one-line and two-line specs, the letter and digit alphabets, the eight usage colour themes and the advisory validator.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/lebanon-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/lebanon:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/lebanon-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/lebanon:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/lebanon-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/lebanon:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/lebanon-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/lebanon:typescript) |

## Quick start

### Install (Kotlin)

Copy `kotlin/src/commonMain/kotlin/plates/countries/lebanon/` into `plate_core/kotlin/src/commonMain/kotlin/plates/countries/`.

Then run the tests from `plate_core/kotlin/`: `./gradlew jvmTest`.

### Use

```kotlin
import plates.countries.lebanon.country

val spec = country.specs["lb.oneLine"]
println(country.pkg)
```

## Specs

The specs are the same in every language (they come from shared data).

- `lb.oneLine`
- `lb.twoLine`

## Themes

- `LebanonThemes.private`
- `LebanonThemes.consular`
- `LebanonThemes.diplomatic`
- `LebanonThemes.publicInstitution`
- `LebanonThemes.drivingSchool`
- `LebanonThemes.transit`
- `LebanonThemes.temporary`
- `LebanonThemes.tourism`

## Change it

- Specs: `country.specs`, by id.
- Themes: `country.themes`.
- Validators: `country.validators` (`LebanonValidator`).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/lebanon-plate/blob/main/LICENSE).

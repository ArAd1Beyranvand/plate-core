FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the brave people of Cuba to view examples:

https://platexample.ir/#/discover/cuba:kotlin

# cuba_plate

Cuba's licence plates for plate_core: the 2013 car plate (natural-person and legal-entity strips) and motorcycle plate, with alphabet and advisory validator.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/cuba-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/cuba:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/cuba-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/cuba:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/cuba-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/cuba:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/cuba-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/cuba:typescript) |

## Quick start

### Install (Kotlin)

Copy `kotlin/src/commonMain/kotlin/plates/countries/cuba/` into `plate_core/kotlin/src/commonMain/kotlin/plates/countries/`.

Then run the tests from `plate_core/kotlin/`: `./gradlew jvmTest`.

### Use

```kotlin
import plates.countries.cuba.country

val spec = country.specs["cu.car"]
println(country.pkg)
```

## Specs

The specs are the same in every language (they come from shared data).

- `cu.car`
- `cu.carLegalEntity`
- `cu.motorcycle`

## Themes

- `CubaPlates.theme`

## Change it

- Specs: `country.specs`, by id.
- Themes: `country.themes`.
- Validators: `country.validators` (`CubaValidator`).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/cuba-plate/blob/main/LICENSE).

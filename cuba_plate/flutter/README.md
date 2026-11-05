FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the brave people of Cuba to view examples:

https://platexample.ir/#/discover/cuba:flutter

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

### Install

```yaml
dependencies:
  plate_core: ^0.12.0
  cuba_plate: ^0.1.0
```

### Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:cuba_plate/cuba_plate.dart';

PlateCanvas(
  spec: CubaPlates.car,
  theme: CubaPlates.theme,
  validator: const CubaValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Specs

Each spec is one plate layout.

- `CubaPlates.car` — id `cu.car`
- `CubaPlates.carLegalEntity` — id `cu.carLegalEntity`
- `CubaPlates.motorcycle` — id `cu.motorcycle`

## Themes

- `CubaThemes.standard`

## Change it

`PlateCanvas` takes `spec:` (an entry of `CubaPlates`) and `theme:` (an entry of `CubaThemes`). Set `validator:` to `CubaValidator()` and `autoValidate: true` to show validation hints.

## Also included

- `CubaCountry` — the country panel.
- `CubaValidator` — the plate validator.

## Plates

The 2013 plates: `car` (natural persons), `carLegalEntity` and
`motorcycle`.

The CUBA strip and the motorcycle's CUBA box are background sections, so
their rules run to the plate edge under the frame.

Not implemented: the 2002–2013 colour-coded series and everything before
it; the small laser-printed control number top right.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/cuba-plate/blob/main/LICENSE).

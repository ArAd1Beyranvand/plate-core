FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the bold people of Venezuela to view examples:

https://platexample.ir/#/discover/venezuela:flutter

# venezuela_plate

Venezuela's licence plate for the plate_core library — the 2008 car plate with the flag background, the state-code alphabets and the advisory category validator.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/venezuela-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/venezuela:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/venezuela-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/venezuela:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/venezuela-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/venezuela:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/venezuela-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/venezuela:typescript) |

## Quick start

### Install

```yaml
dependencies:
  plate_core: ^0.12.0
  venezuela_plate: ^0.1.0
```

### Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:venezuela_plate/venezuela_plate.dart';

PlateCanvas(
  spec: VenezuelaPlates.car,
  theme: VenezuelaPlates.theme,
  validator: const VenezuelaValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Specs

Each spec is one plate layout.

- `VenezuelaPlates.car` — id `ve.car`

## Themes

- `VenezuelaThemes.standard`

## Change it

`PlateCanvas` takes `spec:` (an entry of `VenezuelaPlates`) and `theme:` (an entry of `VenezuelaThemes`). Set `validator:` to `VenezuelaCategory()` and `autoValidate: true` to show validation hints.

## Also included

- `VenezuelaCountry` — the country panel.
- `VenezuelaCategory` — the plate validator.

## Plates

One design for every category of the 2008 plate. The categories differ
only in which of the first six cells are letters (see
`VenezuelaValidator`), so the cells take either. The last letter is the
state, and the state name printed under the serial is a mirror of it
through `VenezuelaAlphabets.stateName` — it follows whatever is typed.

The flag is the background: white, then yellow, blue and red bands rising
across the lower plate, under the characters.

Not implemented: the 1955–2008 series; the motorcycle plate (smaller, and
the article gives no size); the yellow provisional plate and the Free Port
plate, which are different designs; the eight stars on the blue band and
the VENEZUELA microprint on the characters.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/venezuela-plate/blob/main/LICENSE).

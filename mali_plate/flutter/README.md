FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the proud people of Mali to view examples:

https://platexample.ir/#/discover/mali:flutter

# mali_plate

Mali's licence plates for the plate_core library — the simple current series, all black on white.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/mali-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/mali:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/mali-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/mali:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/mali-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/mali:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/mali-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/mali:typescript) |

## Quick start

### Install

```yaml
dependencies:
  plate_core: ^0.12.0
  mali_plate: ^0.1.0
```

### Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:mali_plate/mali_plate.dart';

PlateCanvas(
  spec: MaliPlates.all['standard']!(),
  theme: MaliThemes.standard,
  validator: const MaliValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Specs

Each spec is one plate layout.

- none listed

## Themes

- `MaliThemes.standard`

## Change it

`PlateCanvas` takes `spec:` (an entry of `MaliPlates`) and `theme:` (an entry of `MaliThemes`). Set `validator:` to `MaliValidator()` and `autoValidate: true` to show validation hints.

## Also included

- `MaliCountry` — the country panel.
- `MaliValidator` — the plate validator.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/mali-plate/blob/main/LICENSE).

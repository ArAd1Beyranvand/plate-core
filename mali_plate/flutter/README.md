FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the proud people of Mali to view examples:

https://platexample.ir/#/discover/mali

# mali_plate

Mali's licence plates for the plate_core library — the simple current series, all black on white.

## Install

```yaml
dependencies:
  plate_core: ^0.12.0
  mali_plate: ^0.1.0
```

## Use

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

## Contains

- `MaliCountry` — country panel: `mali`.
- `MaliPlates` — `all`, a map of spec builders: `standard`.
- `MaliThemes` — 1 theme: `standard`.
- `MaliValidator` — advisory validator; flags the frame, never blocks a keystroke.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).


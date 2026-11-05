FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the brave people of Algeria to view examples:

https://platexample.ir/#/discover/algeria:flutter

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

### Install

```yaml
dependencies:
  plate_core: ^0.12.0
  algeria_plate: ^0.1.0
```

### Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:algeria_plate/algeria_plate.dart';

PlateCanvas(
  spec: AlgeriaPlates.singleLine,
  theme: AlgeriaThemes.front,
  validator: const AlgeriaValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Specs

Each spec is one plate layout.

- `AlgeriaPlates.singleLine`
- `AlgeriaPlates.twoLine` — id `dz.twoLine`
- `AlgeriaPlates.diplomatic`
- `AlgeriaPlates.army` — id `dz.army`

## Themes

- `AlgeriaThemes.front`
- `AlgeriaThemes.rear`
- `AlgeriaThemes.diplomatic`
- `AlgeriaThemes.army`

## Change it

`PlateCanvas` takes `spec:` (an entry of `AlgeriaPlates`) and `theme:` (an entry of `AlgeriaThemes`). Set `validator:` to `AlgeriaVehicleClasses()` and `autoValidate: true` to show validation hints.

## Also included

- `AlgeriaCountry` — the country panel.
- `AlgeriaVehicleClasses` — the plate validator.
- `AlgeriaRegions` — code table.

## Plates

Algeria's plate geometries. Front and rear singleLine plates share a spec;
the livery is the theme's.

The civil specs have one field per text group: `serial` (5), `type` (3:
vehicle class then year of manufacture) and `wilaya` (2); diplomatic has
`serial` (1–3), `status` (2) and `mission` (2); army has `serial` (9).

Not implemented: the 140×120 motorcycle plate. The article gives 26 mm
digits with "the rest the same", i.e. 10 mm between them, which cannot
put five digits on a 140 mm row.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/algeria-plate/blob/main/LICENSE).

FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the harmonious people of Malaysia to view examples:

https://platexample.ir/#/discover/malaysia

# malaysia_plate

Malaysia's licence plates for the `plate_core` library. Four geometries: single-row (width follows the registration), two-row, diplomatic `NN-NN-DC` and the 2024 JPJePlate. Taxi, military and consular plates are the single-row geometry on another theme.

## Install

```yaml
dependencies:
  plate_core: ^0.12.0
  malaysia_plate: ^0.1.0
```

## Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:malaysia_plate/malaysia_plate.dart';

PlateCanvas(
  spec: MalaysiaPlates.diplomatic,
  theme: MalaysiaThemes.standard,
  validator: const MalaysiaValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Contains

- `MalaysiaCountry` — country panel: `malaysia`.
- `MalaysiaPlates` — 4 plate specs: `diplomatic`, `singleRow()`, `twoRow()`, `ev()`.
- `MalaysiaThemes` — 5 themes: `standard`, `taxi`, `diplomatic`, `consular`, `ev`.
- `MalaysiaValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `MalaysiaDiplomaticValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `MalaysiaSerialGenerator` — random plate generator.
- `MalaysiaRegions` — code table.

## Plates

* `singleRow`: the standard plate; colour is the theme's. The canvas width
  is derived from the content, since plates are made to the registration.
* `twoRow`: the 247×173 rear/motorcycle plate, prefix over number.
* `diplomatic`: `NN-NN-DC`, condensed characters, one row 236 wide.
* `ev`: the 2024 JPJePlate, 520×110, green strip with flag and `MAL`, then
  a grey security strip.

Text groups are `prefix`, `number` and, when present, `suffix` (diplomatic:
`country`, `serial`, `mission`).

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).


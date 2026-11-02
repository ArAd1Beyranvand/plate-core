FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the brave people of Algeria to view examples:

https://platexample.ir/#/discover/algeria

# algeria_plate

Algeria's licence plates for the `plate_core` library. Every Algerian plate is digits only: `NNNNN NNN NN` — serial, vehicle class and year of manufacture, wilaya. One single-line geometry carries the white front and yellow rear liveries; a two-line geometry, the diplomatic `NNN-NN-NN` plate and the army plate complete the set.

## Install

```yaml
dependencies:
  plate_core: ^0.12.0
  algeria_plate: ^0.1.0
```

## Use

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

## Contains

- `AlgeriaCountry` — country panel: `algeria`.
- `AlgeriaPlates` — 4 plate specs: `singleLine`, `twoLine`, `diplomatic`, `army`.
- `AlgeriaThemes` — 4 themes: `front`, `rear`, `diplomatic`, `army`.
- `AlgeriaValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `AlgeriaDiplomaticValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `AlgeriaSerialGenerator` — random plate generator.
- `AlgeriaRegions` — code table.
- 1 bundled asset (`dz_roundel.png`).

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


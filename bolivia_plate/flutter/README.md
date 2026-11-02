FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the resilient people of Bolivia to view examples:

https://platexample.ir/#/discover/bolivia

# bolivia_plate

Bolivia's licence plates for the `plate_core` library. The ordinary plate is the PTA number `1234ABC` in blue on white under BOLIVIA, with the flag at the left and the department's letter in a box at the right. Diplomatic, consular and international plates (`12-CD-34`) and the Mercosur plate (`AB 12345`) complete the set.

## Install

```yaml
dependencies:
  plate_core: ^0.12.0
  bolivia_plate: ^0.1.0
```

## Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:bolivia_plate/bolivia_plate.dart';

PlateCanvas(
  spec: BoliviaPlates.mercosur,
  theme: BoliviaThemes.standard,
  validator: const BoliviaValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Contains

- `BoliviaCountry` — country panel: `bolivia`.
- `BoliviaPlates` — 3 plate specs: `mercosur`, `standard()`, `special()`.
- `BoliviaThemes` — 6 themes: `standard`, `diplomatic`, `consular`, `mission`, `organization`, `mercosur`.
- `BoliviaValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `BoliviaSpecialValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `BoliviaMercosurValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `BoliviaSerialGenerator` — random plate generator.
- `BoliviaRegions` — code table.
- 1 bundled asset (`Flag_of_Bolivia_state.svg`).

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).


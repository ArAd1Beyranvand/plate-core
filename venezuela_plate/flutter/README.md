FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the bold people of Venezuela to view examples:

https://platexample.ir/#/discover/venezuela

# venezuela_plate

Venezuela's 2008 licence plate for the `plate_core` library. One spec, one theme: the car plate, navy on the flag, with the state name under the serial following the last letter.

## Install

```yaml
dependencies:
  plate_core: ^0.12.0
  venezuela_plate: ^0.1.0
```

## Use

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

## Contains

- `VenezuelaCountry` — country panel: `venezuela`.
- `VenezuelaPlates` — 1 plate spec: `car`.
- `VenezuelaPlates` — 1 theme: `theme`.
- `VenezuelaThemes` — 1 theme: `standard`.
- `VenezuelaValidator` — advisory validator; flags the frame, never blocks a keystroke.

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


FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the brave people of Cuba to view examples:

https://platexample.ir/#/discover/cuba

# cuba_plate

Cuba's 2013 licence plates for the `plate_core` library. Three specs, one theme: a car for natural persons (white CUBA strip), a car for legal entities (blue strip), and a motorcycle.

## Install

```yaml
dependencies:
  plate_core: ^0.12.0
  cuba_plate: ^0.1.0
```

## Use

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

## Contains

- `CubaCountry` — country panel: `cuba`.
- `CubaPlates` — 3 plate specs: `car`, `carLegalEntity`, `motorcycle`.
- `CubaPlates` — 1 theme: `theme`.
- `CubaThemes` — 1 theme: `standard`.
- `CubaValidator` — advisory validator; flags the frame, never blocks a keystroke.

## Plates

The 2013 plates: `car` (natural persons), `carLegalEntity` and
`motorcycle`.

The CUBA strip and the motorcycle's CUBA box are background sections, so
their rules run to the plate edge under the frame.

Not implemented: the 2002–2013 colour-coded series and everything before
it; the small laser-printed control number top right.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).


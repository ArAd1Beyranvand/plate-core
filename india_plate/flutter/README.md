FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the vibrant people of India to view examples:

https://platexample.ir/#/discover/india

# india_plate

India's licence plates for the `plate_core` library. One 500×120 layout for every current format; the colour class (private, transport, rental, electric, diplomatic, ...) is a theme, never a spec.

## Install

```yaml
dependencies:
  plate_core: ^0.12.0
  india_plate: ^0.1.0
```

## Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:india_plate/india_plate.dart';

PlateCanvas(
  spec: IndiaPlates.private,
  theme: IndiaThemes.private,
  validator: const IndiaValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Contains

- `IndiaCountry` — country panel: `india`.
- `IndiaPlates` — 8 plate specs: `private`, `standard`, `bharat`, `vintage`, `military`, `diplomatic`, `temporary`, `trade`.
- `IndiaThemes` — 11 themes: `private`, `transport`, `rental`, `electric`, `electricTransport`, `diplomatic`, `consular`, `military`, `militaryPolice`, `temporary` and 1 more.
- `IndiaValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `IndiaMissions` — code table.
- `IndiaRegions` — code table.
- 1 bundled asset (`in_ashoka_chakra.png`).

## Plates

India's current (1989 Motor Vehicles Act, HSRP) plates.

One layout for every format; colour class is the theme (`IndiaThemes`), so
a yellow transport plate is `standard` in `IndiaThemes.transport`.

Fixed for the cell row: the RTO series is two letters, as on the artwork.
One- and three-letter series and the IOD mission type need a different
cell count and are not specced. Not implemented: the pre-1989 series, the
president's and governors' emblem plates, the laser-etched serial under
IND, and the two-wheeler and commercial-vehicle plate sizes.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).


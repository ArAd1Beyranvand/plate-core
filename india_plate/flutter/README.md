FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the vibrant people of India to view examples:

https://platexample.ir/#/discover/india:flutter

# india_plate

India's licence plates for the plate_core library — the HSRP car plate in every colour class, with the Bharat, vintage, armed-forces, diplomatic, temporary and trade formats.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/india-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/india:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/india-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/india:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/india-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/india:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/india-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/india:typescript) |

## Quick start

### Install

```yaml
dependencies:
  plate_core: ^0.12.0
  india_plate: ^0.1.0
```

### Use

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

## Specs

Each spec is one plate layout.

- `IndiaPlates.private`
- `IndiaPlates.standard`
- `IndiaPlates.bharat`
- `IndiaPlates.vintage`
- `IndiaPlates.military`
- `IndiaPlates.diplomatic`
- `IndiaPlates.temporary`
- `IndiaPlates.trade`

## Themes

- `IndiaThemes.private`
- `IndiaThemes.transport`
- `IndiaThemes.rental`
- `IndiaThemes.electric`
- `IndiaThemes.electricTransport`
- `IndiaThemes.diplomatic`
- `IndiaThemes.consular`
- `IndiaThemes.military`
- `IndiaThemes.militaryPolice`
- `IndiaThemes.temporary`
- `IndiaThemes.trade`

## Change it

`PlateCanvas` takes `spec:` (an entry of `IndiaPlates`) and `theme:` (an entry of `IndiaThemes`). Set `validator:` to `IndiaValidator()` and `autoValidate: true` to show validation hints.

## Also included

- `IndiaCountry` — the country panel.
- `IndiaValidator` — the plate validator.
- `IndiaMissions` — code table.
- `IndiaRegions` — code table.

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

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/india-plate/blob/main/LICENSE).

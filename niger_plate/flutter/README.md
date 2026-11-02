FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the resilient people of Niger to view examples:

https://platexample.ir/#/discover/niger

# niger_plate

Niger's licence plates for the `plate_core` library. The 2005 series: a region digit and series letter, a hologram mark, a four-digit serial, and the country's map over `RN` at the right. Private (black on white, black map) and commercial (black on orange, map in the national colours).

## Install

```yaml
dependencies:
  plate_core: ^0.12.0
  niger_plate: ^0.1.0
```

## Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:niger_plate/niger_plate.dart';

PlateCanvas(
  spec: NigerOtherPlates.state,
  onChooseCharacter: noCharacterChooser,
);
```

## Contains

- `NigerCountry` — country panels: `private`, `commercial`, `plain`, `military`.
- `NigerOtherPlates` — 4 plate specs: `state`, `military`, `diplomaticChief`, `diplomaticStaff`.
- `NigerPlates` — 2 plate specs: `privateSpec`, `commercialSpec`.
- `NigerThemes` — 5 themes: `private`, `commercial`, `stateTransport`, `military`, `diplomatic`.
- `NigerValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `NigerStateValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `NigerMilitaryValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `NigerDiplomaticValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `NigerSerialGenerator` — random plate generator.
- `NigerRegions` — code table.
- 2 bundled assets (`niger_map.svg`, `niger_map_flag.svg`).

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).


FREE PALESTINE 🇵🇸🇮🇷 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the steadfast people of Lebanon to view examples:

https://platexample.ir/#/discover/lebanon

# lebanon_plate

Lebanon's licence plates for the `plate_core` library. Usage (the field colour) and `LebanonLetter` (town or class code) are separate axes by design: `B 123456` and `Z 123456` are the same usage with different letters, while a red and a yellow `M` plate share a letter but differ in usage. A usage selects a theme and band via `LebanonThemes.forUsage` and `LebanonCountry.forUsage`, not a spec.

## Install

```yaml
dependencies:
  plate_core: ^0.12.0
  lebanon_plate: ^0.1.0
```

## Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:lebanon_plate/lebanon_plate.dart';

PlateCanvas(
  spec: LebanonPlates.oneLine,
  theme: LebanonThemes.private,
  validator: const LebanonValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Contains

- `LebanonCountry` — country panels: `band`, `private`, `publicInstitution`.
- `LebanonPlates` — 2 plate specs: `oneLine`, `twoLine`.
- `LebanonThemes` — 8 themes: `private`, `consular`, `diplomatic`, `publicInstitution`, `drivingSchool`, `transit`, `temporary`, `tourism`.
- `LebanonValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `LebanonSerialGenerator` — random plate generator.
- `LebanonRegions` — code table.
- 1 bundled asset (`cedar.svg`).

## Plates

`oneLine` (1040×220, band left) and `twoLine` (520×288, band top). The
number is one slot of one to six digits.

The one-line band text runs vertically on the real plate; here it prints
horizontally (core limitation).

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).


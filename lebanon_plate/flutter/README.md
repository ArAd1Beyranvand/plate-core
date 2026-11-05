FREE PALESTINE 🇵🇸🇮🇷 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the steadfast people of Lebanon to view examples:

https://platexample.ir/#/discover/lebanon:flutter

# lebanon_plate

Lebanon's licence plates for the plate_core library — the one-line and two-line specs, the letter and digit alphabets, the eight usage colour themes and the advisory validator.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/lebanon-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/lebanon:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/lebanon-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/lebanon:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/lebanon-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/lebanon:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/lebanon-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/lebanon:typescript) |

## Quick start

### Install

```yaml
dependencies:
  plate_core: ^0.12.0
  lebanon_plate: ^0.1.0
```

### Use

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

## Specs

Each spec is one plate layout.

- `LebanonPlates.oneLine` — id `lb.oneLine`
- `LebanonPlates.twoLine` — id `lb.twoLine`

## Themes

- `LebanonThemes.private`
- `LebanonThemes.consular`
- `LebanonThemes.diplomatic`
- `LebanonThemes.publicInstitution`
- `LebanonThemes.drivingSchool`
- `LebanonThemes.transit`
- `LebanonThemes.temporary`
- `LebanonThemes.tourism`
- `LebanonThemes.forUsage`(…)

## Change it

`PlateCanvas` takes `spec:` (an entry of `LebanonPlates`) and `theme:` (an entry of `LebanonThemes`). Set `validator:` to `LebanonValidator()` and `autoValidate: true` to show validation hints.

## Also included

- `LebanonCountry` — the country panel.
- `LebanonValidator` — the plate validator.
- `LebanonRegions` — code table.

## Plates

`oneLine` (1040×220, band left) and `twoLine` (520×288, band top). The
number is one slot of one to six digits.

The one-line band text runs vertically on the real plate; here it prints
horizontally (core limitation).

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/lebanon-plate/blob/main/LICENSE).

FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the resilient people of Niger to view examples:

https://platexample.ir/#/discover/niger:flutter

# niger_plate

Niger's licence plates for plate_core: the 2005 series in private and commercial liveries, with themes, alphabets and advisory validators.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/niger-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/niger:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/niger-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/niger:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/niger-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/niger:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/niger-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/niger:typescript) |

## Quick start

### Install

```yaml
dependencies:
  plate_core: ^0.12.0
  niger_plate: ^0.1.0
```

### Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:niger_plate/niger_plate.dart';

PlateCanvas(
  spec: NigerOtherPlates.state,
  onChooseCharacter: noCharacterChooser,
);
```

## Specs

Each spec is one plate layout.

- `NigerOtherPlates.state`
- `NigerOtherPlates.military`
- `NigerOtherPlates.diplomaticChief`
- `NigerOtherPlates.diplomaticStaff`
- `NigerOtherPlates.privateSpec`
- `NigerOtherPlates.commercialSpec`

## Themes

- `NigerThemes.private`
- `NigerThemes.commercial`
- `NigerThemes.stateTransport`
- `NigerThemes.military`
- `NigerThemes.diplomatic`
- `NigerThemes.forUsage`(…)

## Change it

`PlateCanvas` takes `spec:` (an entry of `NigerOtherPlates`) and `theme:` (an entry of `NigerThemes`). Set `validator:` to `NigerValidator()` and `autoValidate: true` to show validation hints.

## Also included

- `NigerCountry` — the country panel.
- `NigerValidator` — the plate validator.
- `NigerOtherRegions` — code table.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/niger-plate/blob/main/LICENSE).

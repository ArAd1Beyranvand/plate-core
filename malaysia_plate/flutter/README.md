FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the harmonious people of Malaysia to view examples:

https://platexample.ir/#/discover/malaysia:flutter

# malaysia_plate

Malaysia's licence plates for plate_core: single-row and two-row JPJ plates, the diplomatic plate and JPJePlate, with themes, alphabets and an advisory validator.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/malaysia-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/malaysia:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/malaysia-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/malaysia:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/malaysia-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/malaysia:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/malaysia-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/malaysia:typescript) |

## Quick start

### Install

```yaml
dependencies:
  plate_core: ^0.12.0
  malaysia_plate: ^0.1.0
```

### Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:malaysia_plate/malaysia_plate.dart';

PlateCanvas(
  spec: MalaysiaPlates.diplomatic,
  theme: MalaysiaThemes.standard,
  validator: const MalaysiaValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Specs

Each spec is one plate layout.

- `MalaysiaPlates.singleRow`(…)
- `MalaysiaPlates.twoRow`(…)
- `MalaysiaPlates.ev`(…)
- `MalaysiaPlates.diplomatic` — id `my.diplomatic`

## Themes

- `MalaysiaThemes.standard`
- `MalaysiaThemes.taxi`
- `MalaysiaThemes.diplomatic`
- `MalaysiaThemes.consular`
- `MalaysiaThemes.ev`

## Change it

`PlateCanvas` takes `spec:` (an entry of `MalaysiaPlates`) and `theme:` (an entry of `MalaysiaThemes`). Set `validator:` to `MalaysiaValidator()` and `autoValidate: true` to show validation hints.

## Also included

- `MalaysiaCountry` — the country panel.
- `MalaysiaValidator` — the plate validator.
- `MalaysiaRegions` — code table.

## Plates

* `singleRow`: the standard plate; colour is the theme's. The canvas width
  is derived from the content, since plates are made to the registration.
* `twoRow`: the 247×173 rear/motorcycle plate, prefix over number.
* `diplomatic`: `NN-NN-DC`, condensed characters, one row 236 wide.
* `ev`: the 2024 JPJePlate, 520×110, green strip with flag and `MAL`, then
  a grey security strip.

Text groups are `prefix`, `number` and, when present, `suffix` (diplomatic:
`country`, `serial`, `mission`).

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/malaysia-plate/blob/main/LICENSE).

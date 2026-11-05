FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the resilient people of Bolivia to view examples:

https://platexample.ir/#/discover/bolivia:flutter

# bolivia_plate

Bolivia's licence plates for plate_core: standard, diplomatic, consular and Mercosur plates, with themes, alphabets and advisory validators.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/bolivia-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/bolivia:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/bolivia-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/bolivia:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/bolivia-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/bolivia:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/bolivia-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/bolivia:typescript) |

## Quick start

### Install

```yaml
dependencies:
  plate_core: ^0.12.0
  bolivia_plate: ^0.1.0
```

### Use

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

## Specs

Each spec is one plate layout.

- `BoliviaService.standard`(…)
- `BoliviaService.special`(…)
- `BoliviaService.mercosur` — id `bo.mercosur`

## Themes

- `BoliviaThemes.standard`
- `BoliviaThemes.diplomatic`
- `BoliviaThemes.consular`
- `BoliviaThemes.mission`
- `BoliviaThemes.organization`
- `BoliviaThemes.mercosur`

## Change it

`PlateCanvas` takes `spec:` (an entry of `BoliviaService`) and `theme:` (an entry of `BoliviaThemes`). Set `validator:` to `BoliviaValidator()` and `autoValidate: true` to show validation hints.

## Also included

- `BoliviaCountry` — the country panel.
- `BoliviaValidator` — the plate validator.
- `BoliviaService` — code table.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/bolivia-plate/blob/main/LICENSE).

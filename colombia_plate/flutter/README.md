FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the warm people of Colombia to view examples:

https://platexample.ir/#/discover/colombia:flutter

# colombia_plate

Colombia's licence plates for plate_core: private, public-service, official, diplomatic and police plates, with themes, alphabets and advisory validators.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/colombia-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/colombia:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/colombia-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/colombia:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/colombia-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/colombia:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/colombia-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/colombia:typescript) |

## Quick start

### Install

```yaml
dependencies:
  plate_core: ^0.12.0
  colombia_plate: ^0.1.0
```

### Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:colombia_plate/colombia_plate.dart';

PlateCanvas(
  spec: ColombiaPlates.police,
  theme: ColombiaThemes.private,
  validator: const ColombiaValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Specs

Each spec is one plate layout.

- `ColombiaSeries.standard`(…)
- `ColombiaSeries.police` — id `co.police`
- `ColombiaSeries.diplomatic` — id `co.cd`

## Themes

- `ColombiaThemes.private`
- `ColombiaThemes.commercial`
- `ColombiaThemes.official`
- `ColombiaThemes.antique`
- `ColombiaThemes.tank`
- `ColombiaThemes.consular`
- `ColombiaThemes.organization`
- `ColombiaThemes.staff`
- `ColombiaThemes.police`
- `ColombiaThemes.diplomatic`

## Change it

`PlateCanvas` takes `spec:` (an entry of `ColombiaSeries`) and `theme:` (an entry of `ColombiaThemes`). Set `validator:` to `ColombiaValidator()` and `autoValidate: true` to show validation hints.

## Also included

- `ColombiaCountry` — the country panel.
- `ColombiaValidator` — the plate validator.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/colombia-plate/blob/main/LICENSE).

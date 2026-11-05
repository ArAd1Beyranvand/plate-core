FREE PALESTINE 🇵🇸🇮🇷 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the free people of Palestine to view examples:

https://platexample.ir/#/discover/palestine:flutter

# palestine_plate

Palestine's licence plates for the plate_core library — the West Bank and Gaza specs, the alphabets, the usage themes and the advisory validators.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/palestine-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/palestine:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/palestine-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/palestine:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/palestine-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/palestine:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/palestine-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/palestine:typescript) |

## Quick start

### Install

```yaml
dependencies:
  plate_core: ^0.12.0
  palestine_plate: ^0.3.0
```

### Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:palestine_plate/palestine_plate.dart';

PlateCanvas(
  spec: PSGazaPlates.car2012,
  validator: const PSGazaValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Specs

Each spec is one plate layout.

- `PSGazaPlates.car2012` — id `ps.gz.2012.car`
- `PSGazaPlates.moto` — id `ps.gz.moto`
- `PSGazaPlates.car2012TwoLine` — id `ps.gz.2012.car2l`
- `PSGazaPlates.car2021TwoLine` — id `ps.gz.2021.car2l`
- `PSGazaPlates.modernCar` — id `ps.wb.modern.car`
- `PSGazaPlates.legacyCar` — id `ps.wb.legacy.car`
- `PSGazaPlates.modernCarTwoLine` — id `ps.wb.modern.car2l`
- `PSGazaPlates.legacyCarTwoLine` — id `ps.wb.legacy.car2l`
- `PSGazaPlates.modernMoto` — id `ps.wb.modern.moto`
- `PSGazaPlates.modernMotoTwoLine` — id `ps.wb.modern.moto2l`
- `PSGazaPlates.modernTrade` — id `ps.wb.modern.trade`

## Themes

- `PSThemes.greenOnWhite`
- `PSThemes.whiteOnGreen`
- `PSThemes.redOnWhite`
- `PSThemes.whiteOnBlue`
- `PSThemes.forUsage`(…)
- `PSThemes.gazaBlack`
- `PSThemes.gazaGreen`
- `PSThemes.gazaBlue`
- `PSThemes.gazaRed`

## Change it

`PlateCanvas` takes `spec:` (an entry of `PSGazaPlates`) and `theme:` (an entry of `PSThemes`). Set `validator:` to `PSWestBankModernValidator()` and `autoValidate: true` to show validation hints.

## Also included

- `PSCountries` — the country panel.
- `PSWestBankModernValidator` — the plate validator.

## Plates

West Bank plate designs: modern (D·DDDD·L, since 2018) and legacy
(D·DDDD·DD, 1994–2018). Only `modernCar` is measured from reference_plate.png;
every other form factor is provisional. The host supplies the theme
(`PSThemes.forUsage`) and, for legacy plates, `legacyCountryForUsage`.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/palestine-plate/blob/main/LICENSE).

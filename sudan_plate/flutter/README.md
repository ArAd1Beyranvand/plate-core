FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the resilient people of Sudan to view examples:

https://platexample.ir/#/discover/sudan:flutter

# sudan_plate

Sudan's licence plates for plate_core: the bilingual 2009 plate in private, bus-and-taxi and commercial liveries, with themes, alphabets and advisory validators.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/sudan-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/sudan:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/sudan-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/sudan:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/sudan-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/sudan:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/sudan-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/sudan:typescript) |

## Quick start

### Install

```yaml
dependencies:
  plate_core: ^0.12.0
  sudan_plate: ^0.1.0
```

### Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:sudan_plate/sudan_plate.dart';

PlateCanvas(
  spec: SudanPlates.standard,
  theme: SudanThemes.private,
  validator: const SudanValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Specs

Each spec is one plate layout.

- `SudanPlates.standard` — id `sd.2009`

## Themes

- `SudanThemes.private`
- `SudanThemes.transport`
- `SudanThemes.commercial`
- `SudanThemes.forUsage`(…)

## Change it

`PlateCanvas` takes `spec:` (an entry of `SudanPlates`) and `theme:` (an entry of `SudanThemes`). Set `validator:` to `SudanValidator()` and `autoValidate: true` to show validation hints.

## Also included

- `SudanCountry` — the country panel.
- `SudanValidator` — the plate validator.

## Plates

The 2009 bilingual plate; every livery is this design, themed by
`SudanThemes`.

The value is `class · state · serial`, stored in Latin (`7 KH 10346`). Each
slot prints in Arabic above a Latin echo; both rows are editable.

Not built: the newer print with the hologram replaced by embossed text, and
the pre-2009 series.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/sudan-plate/blob/main/LICENSE).

FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the brave people of Tunisia to view examples:

https://platexample.ir/#/discover/tunisia:flutter

# tunisia_plate

Tunisia's licence plates for plate_core: one- and two-line, rental, government, diplomatic, military and temporary plates, with themes, alphabets and validators.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/tunisia-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/tunisia:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/tunisia-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/tunisia:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/tunisia-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/tunisia:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/tunisia-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/tunisia:typescript) |

## Quick start

### Install

```yaml
dependencies:
  plate_core: ^0.12.0
  tunisia_plate: ^0.1.0
```

### Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:tunisia_plate/tunisia_plate.dart';

PlateCanvas(
  spec: TunisiaPlates.standard,
  theme: TunisiaThemes.standard,
  validator: const TunisiaValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Specs

Each spec is one plate layout.

- `TunisiaMission.standard`
- `TunisiaMission.square`
- `TunisiaMission.government`
- `TunisiaMission.diplomatic`(…)
- `TunisiaMission.temporary`(…)
- `TunisiaMission.military`

## Themes

- `TunisiaThemes.standard`
- `TunisiaThemes.rental`
- `TunisiaThemes.government`
- `TunisiaThemes.diplomatic`
- `TunisiaThemes.military`

## Change it

`PlateCanvas` takes `spec:` (an entry of `TunisiaMission`) and `theme:` (an entry of `TunisiaThemes`). Set `validator:` to `TunisiaValidator()` and `autoValidate: true` to show validation hints.

## Also included

- `TunisiaCountry` — the country panel.
- `TunisiaValidator` — the plate validator.

## Plates

* `standard`: 520x110, `NNN تونس NNNN`. Ordinary and rental cars differ
  by theme.
* `square`: the 275x200 two-line rear plate, number over series and تونس.
* `government`: `NN - NNNNNN`, ministry and vehicle.
* `diplomatic`: `NN CD س د NN`; `MD` and `CMD` by `TunisiaMission`.
* `military`: five digits with the flag at the left.
* `temporary`: `NNNNN - ن ت`, or `ع ع` for a dealer (`TunisiaSuffix`).

Not implemented: the motorcycle plate (its one photo is too small and
shows an undocumented format), the pre-1975 series, and the sticker on the
military photo. Screw holes are not printed.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/tunisia-plate/blob/main/LICENSE).

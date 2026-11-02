FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the resilient people of Sudan to view examples:

https://platexample.ir/#/discover/sudan

# sudan_plate

Sudan's licence plates for the `plate_core` library. The 2009 bilingual plate: SUDAN / السودان over a rule, then a class digit and state code beside a four- or five-digit serial, each printed in Arabic over a Latin echo of the same value. Private, bus-and-taxi and commercial liveries.

## Install

```yaml
dependencies:
  plate_core: ^0.12.0
  sudan_plate: ^0.1.0
```

## Use

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

## Contains

- `SudanCountry` — country panel: `sudan`.
- `SudanPlates` — 1 plate spec: `standard`.
- `SudanThemes` — 3 themes: `private`, `transport`, `commercial`.
- `SudanValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `SudanSerialGenerator` — random plate generator.

## Plates

The 2009 bilingual plate; every livery is this design, themed by
`SudanThemes`.

The value is `class · state · serial`, stored in Latin (`7 KH 10346`). Each
slot prints in Arabic above a Latin echo; both rows are editable.

Not built: the newer print with the hologram replaced by embossed text, and
the pre-2009 series.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).


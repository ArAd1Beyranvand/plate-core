FREE PALESTINE 🇵🇸🇮🇷 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the noble people of Yemen to view examples:

https://platexample.ir/#/discover/yemen

# yemen_plate

Yemen's licence plates for `plate_core`. Two plate systems are current side by side: A, the 2026 unified white plate with a light-blue side panel, and B, the 1993 northern format of stacked registers coloured by usage. The south issues its own (Aden, Taiz, and the coloured-strip plates of Hadhramaut, Al Mahrah, Shabwah and Marib), as does Riyadh.

## Install

```yaml
dependencies:
  plate_core: ^0.12.0
  yemen_plate: ^0.3.0
```

## Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:yemen_plate/yemen_plate.dart';

PlateCanvas(
  spec: YemenNorthernPlates.car,
  validator: const YemenNorthernValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Contains

- `YemenNorthernPlates` — 2 plate specs: `car`, `moto`.
- `RiyadhPlates` — 4 plate specs: `us`, `diplomatic`, `eu`, `euDiplomatic`.
- `YemenAdenPlates` — 2 plate specs: `oneLine`, `twoLine`.
- `YemenTaizPlates` — 1 plate spec: `temporary`.
- `YemenGovernoratePlates` — 16 plate specs: `hadhramaut`, `hadhramautTemporary`, `hadhramautPolice`, `hadhramautMotorcycle`, `alMahrah`, `alMahrahMotorcycle`, `shabwah`, `shabwahTemporary`, `shabwahPolice`, `shabwahMotorcycle`, `marib`, `maribMotorcycle`, `car()`, `temporary()` and 2 more.
- `YemenUnifiedPlates` — 2 plate specs: `car`, `moto`.
- 2 bundled assets (`aden_lighthouse.png`, `emblem.svg`).

Each also ships its `…Country` panel, `…Themes` and, where one exists, an advisory `…Validator`.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).


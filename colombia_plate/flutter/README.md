FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the warm people of Colombia to view examples:

https://platexample.ir/#/discover/colombia

# colombia_plate

Colombia's licence plates for the `plate_core` library. The ordinary plate is `ABC·123` split by the transport ministry's roundel, the municipality of issue under it; its liveries and series cover private, public-service, official, antique, mototaxi, trailer, tank-truck and diplomatic-staff vehicles. The new diplomatic-corps plate (`A FR 000`) and the National Police plate (`60-0007`) complete the set.

## Install

```yaml
dependencies:
  plate_core: ^0.12.0
  colombia_plate: ^0.1.0
```

## Use

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

## Contains

- `ColombiaCountry` — country panel: `colombia`.
- `ColombiaPlates` — 3 plate specs: `police`, `diplomatic`, `standard()`.
- `ColombiaThemes` — 10 themes: `private`, `commercial`, `official`, `antique`, `tank`, `consular`, `organization`, `staff`, `police`, `diplomatic`.
- `ColombiaValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `ColombiaPoliceValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `ColombiaDiplomaticValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `ColombiaSerialGenerator` — random plate generator.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).


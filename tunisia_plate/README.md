FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the brave people of Tunisia to view examples:

https://platexample.ir/#/discover/tunisia

# tunisia_plate

Tunisia's licence plates for the `plate_core` library. The ordinary plate is `NNN تونس NNNN` — series, the word "Tunisia", registration — on one line or, at the rear, on two. Rental, government, diplomatic, military and temporary plates complete the set.

## Install

```yaml
dependencies:
  plate_core: ^0.12.0
  tunisia_plate: ^0.1.0
```

## Use

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

## Contains

- `TunisiaCountry` — country panel: `tunisia`.
- `TunisiaPlates` — 6 plate specs: `standard`, `square`, `government`, `military`, `diplomatic()`, `temporary()`.
- `TunisiaThemes` — 5 themes: `standard`, `rental`, `government`, `diplomatic`, `military`.
- `TunisiaValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `TunisiaGovernmentValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `TunisiaDiplomaticValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `TunisiaSerialValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `TunisiaSerialGenerator` — random plate generator.

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


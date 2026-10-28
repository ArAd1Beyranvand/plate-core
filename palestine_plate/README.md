FREE PALESTINE 🇵🇸🇮🇷 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the free people of Palestine to view examples:

https://platexample.ir/#/discover/palestine

# palestine_plate

Palestine's licence plates for `plate_core`: the West Bank (`ف / P` block) and Gaza (flag) are two designs, each with its own specs and validators. Colour is derived from usage via `PSThemes.forUsage`. 

## Install

```yaml
dependencies:
  plate_core: ^0.12.0
  palestine_plate: ^0.3.0
```

## Use

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

## Contains

- `PSCountries` — country panels: `westBankGreenInk`, `westBankWhiteInk`, `westBankRedInk`, `westBankGreenInkInline`, `westBankGreenInkBlank`, `gaza2012`, `gaza2021`.
- `PSGazaPlates` — 4 plate specs: `car2012`, `moto`, `car2012TwoLine`, `car2021TwoLine`.
- `PSWestBankPlates` — 7 plate specs: `modernCar`, `legacyCar`, `modernCarTwoLine`, `legacyCarTwoLine`, `modernMoto`, `modernMotoTwoLine`, `modernTrade`.
- `PSThemes` — 8 themes: `greenOnWhite`, `whiteOnGreen`, `redOnWhite`, `whiteOnBlue`, `gazaBlack`, `gazaGreen`, `gazaBlue`, `gazaRed`.
- `PSWestBankModernValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `PSWestBankLegacyValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `PSGazaValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `PSSerialGenerator` — random plate generator.
- 1 bundled asset (`palestine_watermark.png`).

## Plates

West Bank plate designs: modern (D·DDDD·L, since 2018) and legacy
(D·DDDD·DD, 1994–2018). Only `modernCar` is measured from reference_plate.png;
every other form factor is provisional. The host supplies the theme
(`PSThemes.forUsage`) and, for legacy plates, `legacyCountryForUsage`.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).


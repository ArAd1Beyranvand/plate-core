FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the friendly people of Indonesia to view examples:

https://platexample.ir/#/discover/indonesia:flutter

# indonesia_plate

Indonesia's licence plates for plate_core: car, motorcycle, diplomatic, armed-forces and police plates, with usage and EV liveries and advisory validators.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/indonesia-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/indonesia:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/indonesia-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/indonesia:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/indonesia-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/indonesia:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/indonesia-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/indonesia:typescript) |

## Quick start

### Install

```yaml
dependencies:
  plate_core: ^0.12.0
  indonesia_plate: ^0.2.0
```

### Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:indonesia_plate/indonesia_plate.dart';

PlateCanvas(
  spec: IndonesiaPlates.car,
  theme: IndonesiaThemes.private,
  validator: const IndonesiaValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Specs

Each spec is one plate layout.

- `IndonesiaPlates.car`
- `IndonesiaPlates.motorcycle`
- `IndonesiaPlates.diplomatic`
- `IndonesiaPlates.military`(…)
- `IndonesiaPlates.police`

## Themes

- `IndonesiaThemes.private`
- `IndonesiaThemes.public`
- `IndonesiaThemes.government`
- `IndonesiaThemes.freeTradeZone`
- `IndonesiaThemes.privateEv`
- `IndonesiaThemes.publicEv`
- `IndonesiaThemes.governmentEv`
- `IndonesiaThemes.freeTradeZoneEv`
- `IndonesiaThemes.diplomatic`
- `IndonesiaThemes.diplomaticEv`
- `IndonesiaThemes.army`
- `IndonesiaThemes.navy`
- `IndonesiaThemes.airForce`
- `IndonesiaThemes.armedForces`
- `IndonesiaThemes.police`

## Change it

`PlateCanvas` takes `spec:` (an entry of `IndonesiaPlates`) and `theme:` (an entry of `IndonesiaThemes`). Set `validator:` to `IndonesiaAreaCodes()` and `autoValidate: true` to show validation hints.

## Also included

- `IndonesiaCountry` — the country panel.
- `IndonesiaAreaCodes` — the plate validator.
- `IndonesiaRegions` — code table.

## Plates

The 2023-series geometries.

* `car` — 460×135, FE-Schrift serial over a centred `MM · YY` expiry row.
* `motorcycle` — 275×115, DIN serial over a right-aligned expiry row.
* `diplomatic` — the car plate with `CD`/`CC`, the mission's number and
  the vehicle's, always over a band.

`carEv` and `motorcycleEv` fill the lower region in the theme's divider
colour, which the EV themes set to blue. The usage classes — private,
public, government, free-trade zone — are themes on the same spec.

A registration is `B 1945 PKL`: one to two area letters, one to four
digits, one to three suffix letters. Each is one slot sized for its
longest run and centred in its box, so a shorter value sits mid-field. A
plate with no suffix is not specced: the slot needs at least one letter.

Text groups: `prefix`, `number`, `suffix`, `month`, `year`;
diplomatic: `mission`, `country`, `serial`, `month`, `year`; military:
`number`, `suffix`; police: `region`, `number`, `suffix`.

## Military and police

No artwork exists — Commons has photographs only — so these are measured
off photographs, each normalised to 460 mm wide. No size is documented:
the civilian width is kept and the height is the median measured aspect
(3.31, 3.37, 3.14, 3.41, 3.29), 460×138.

* `military` — a yellow rim; on the left a red square with the TNI crest
  in yellow, closed by a yellow upright running rim to rim; the service's
  field with its mark centred at the top and the serial `NNNNN-SS` in
  yellow below. The square and upright are background columns. Army:
  square to x 123, upright 123–137, star x 262–301, serial centres 160
  196 233.5 271 308, dash 343.5, suffix 379.5 422. Navy: upright
  115–124, anchor x 270–308. Content is centred on the field.
* `police` — the same frame on near-black, the square left in the field
  colour with the Polri crest; the field is split by a 4 mm yellow rule at
  y 63 into the region numeral (ink y 15–56, centre x 298) over the
  serial (ink y 76–125, centres 190.5 226 261.5 297, dash 332, suffix 368
  404). Upright 133–140.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/indonesia-plate/blob/main/LICENSE).

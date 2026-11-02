FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

# plate_core

Data-driven vehicle licence plates for Flutter. A plate is a `const PlateSpec` — canvas geometry, a country panel, slots over alphabets, optional chrome — and the widget layer paints whatever the spec says. Adding a plate means adding a const, never a widget.

`plate_core` knows no country and ships no assets. Countries live in their own packages (`iran_plate`, `germany_plate`, … 180+ of them); this package is the engine they all share.

## Install

```yaml
dependencies:
  plate_core: ^0.12.1
  iran_plate: ^0.6.0   # any country package
```

## Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:iran_plate/iran_plate.dart';

PlateCanvas(
  spec: IranPlates.civil,
  theme: IranThemes.blackOnWhite,
  onChooseCharacter: noCharacterChooser,
);
```

That is a complete, editable plate: no provider, no bloc, no `Scaffold`. A `PlateCanvas` owns its characters in a `PlateController` (a `ChangeNotifier`); pass `controller:` to read or write the value, follow the active slot, or feed characters from your own keypad. Swapping `spec:` on a live canvas carries the value across, matching registers by group key (`onSpecChange` tunes that).

`onChooseCharacter` is called for slots whose alphabet is *chosen* rather than typed. Pass `PlateCharacterPicker.show` from [`plate_keypad`](https://pub.dev/packages/plate_keypad), or `noCharacterChooser` when no slot needs one.

## The model

| Type | Role |
| --- | --- |
| `PlateSpec` | the plate: size, panel, slots, text groups, labels, mirrors |
| `PlateSlot` + `PlateAlphabet` | one run of characters and what it may hold (`typed` or `chosen`) |
| `PlateCountry` | the panel: flag (`PlateDrawing`, SVG or raster), wording |
| `PlateTheme` | colours; a spec can `resolveTheme` / `resolveRegion` from what was typed |
| `PlateValidator` | judges a plate — advisory, never blocks a keystroke |
| `PlateRestriction` | the one exception: values a spec refuses outright |
| `PlateController` | the characters, the active slot, validation, `rejection` |
| `PlateInputSource` | lets the host push characters in from its own UI |

One spec per *shape*: what varies per vehicle is a slot, what varies by value is a resolver. A taxi and a private car are one spec with two themes, not two specs.

## Rules of the package

- No country knowledge. A country name anywhere in `lib/`, even in a comment, is a bug.
- No input policing beyond a spec's own `PlateRestriction`.
- No keyboard, no state-management opinion.
- Flags can be drawn in code (`PlateDrawing`, `EuropeanStars`) so a country package ships no file for them.

Whatever `package:plate_core/plate_core.dart` exports is API; everything else under `lib/src/` may change without notice. See `CHANGELOG.md` for the history.

## Part of plate

[`plate_alphabet`](https://pub.dev/packages/plate_alphabet) — shared digit and letter alphabets. [`plate_keypad`](https://pub.dev/packages/plate_keypad) — on-screen keypad and slot picker. Demo gallery of every plate: `plate_number_holder`.

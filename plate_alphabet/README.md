FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

# plate_alphabet

The alphabets plates are typed from: digit sets, letter sets and per-country character tables, shared by every country package so none restates ten digits or twenty-six letters.

Each alphabet is a const `PlateAlphabet` from [`plate_core`](https://pub.dev/packages/plate_core) — which characters a slot accepts, how each is drawn (`glyphs`), and whether it is typed or chosen from a picker.

## Install

```yaml
dependencies:
  plate_alphabet: ^0.1.1
```

## Use

```dart
import 'package:plate_alphabet/plate_alphabet.dart';

PlateAlphabetDigits.iranian;      // 0–9, stored as ASCII, drawn as ۰–۹
PlateAlphabetLatin.letters;       // A–Z from the keyboard
PlateAlphabetLetters.latinAll;    // A–Z for a picker
PersianAlphabets.privateLetters;  // the 13 series letters of an Iranian private plate
GermanAlphabets.districtLetters;  // a country's own table
```

## What is in it

- **Shared sets** — `PlateAlphabetDigits` (`english`, `iranian`, `iranshahr`), `PlateAlphabetLetters` (`latinAll`, `persianAll`), `PlateAlphabetLatin` (`typed`, `letters`, `region`).
- **Script sets** — `PersianAlphabets`, and the Hangul, Belarusian and Namibian tables (`PlateAlphabetKorea`, `PlateAlphabetBelarus`, `PlateAlphabetNamibia`) and the country classes that print other scripts.
- **Per-country tables** — one `<Country>Alphabets` class per country, in `lib/src/countries/`: district and region codes, fixed class letters, forbidden letters left out. A country package re-exports only its own.

Digits are always stored as ASCII `0-9`; only rendering differs, so a value typed in one script validates and converts in any other.

Where a country restricts a set (Peru's special series, Namibia's town codes), the alphabet carries the restriction, so the keypad never offers a combination that cannot exist.

## Part of plate

[`plate_core`](https://pub.dev/packages/plate_core) paints plates; [`plate_keypad`](https://pub.dev/packages/plate_keypad) renders these alphabets as a keypad or picker; each `*_plate` country package depends on this one.

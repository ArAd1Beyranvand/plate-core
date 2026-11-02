## Unreleased

- Each field (prefix, number, suffix, and the diplomatic country, serial and mission) is one `PlateSlot` with a `length` instead of a `plateRegister` of single cells. A value is one string per slot: `['QAB', '8557', 'K']`.
- Removed `MalaysiaFormat`, `prefixLengths`, `digitLengths` and the `prefix:` and `digits:` parameters of `singleRow`, `twoRow` and `ev`; only `suffix:` remains. The canvas is no longer sized to the registration but to three letters and four digits, so a shorter registration centres in its fields.

## 0.1.0

First pub.dev release.
